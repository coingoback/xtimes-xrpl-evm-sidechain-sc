// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract TreasuryOwnable is Ownable, AccessControl {
    address private _treasure;

    /** @dev Can issue, pause, transfer and burn tokens directly from/to the treasure */
    bytes32 public constant TREASURY_TREASURER = keccak256("TREASURY_TREASURER");

    /** @dev Can transfer and burn directly from treasure */
    bytes32 public constant TREASURY_SECRETARY = keccak256("TREASURY_SECRETARY");

    /** @dev Can appoint and dismiss secretaries  */
    bytes32 public constant TREASURY_SECRETARY_MANAGER = keccak256("TREASURY_SECRETARY_MANAGER");

    enum TreasureOperationType {
        IssueToken,
        BurnToken,
        TransferToken
    }

    struct TreasureOperationLimits {
        mapping(TreasureOperationType => uint256) maxAmount;
    }

    mapping(bytes32 treasuryRole => TreasureOperationLimits) private _treasuryOperationAmountLimits;

    error UndefinedTreasure();

    error TreasureInvalidAddress(address treasure);
    error TreasureAlreadyDefined(address treasure, address treasureCandidate);

    error TreasuryInvalidTresurer(address treasurer);
    error TreasuryInvalidSecretary(address secretary);

    error TreasuryUnauthorizedSecretaryAppointment(address sender);
    error TreasuryUnauthorizedTreasureOperation(address account, TreasureOperationType oprType, bytes32 minimumRequiredRole, uint256 amount);

    error TreasuryOperationInvalidAmount(address account, uint256 amount);
    error TreasuryOperationExceedsLimitPerTransaction(address account, bytes32 role, uint256 amount, TreasureOperationType oprType, uint256 maxAmount);

    event TreasurerAppointed(address treasurer);
    event TreasurerDismissed(address treasurer);

    event SecretaryAppointed(address secretary);
    event SecretaryDismissed(address secretary);

    constructor() Ownable(_msgSender()) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(TREASURY_SECRETARY_MANAGER, _msgSender());

        _setRoleAdmin(TREASURY_SECRETARY, TREASURY_SECRETARY_MANAGER);
    }

    modifier canIssue(uint256 amount) {
        _checkTreasureOperation(TreasureOperationType.IssueToken, TREASURY_TREASURER, amount);
        _;
    }

    modifier canBurn(uint256 amount) {
        _checkTreasureOperation(TreasureOperationType.BurnToken, TREASURY_SECRETARY, amount);
        _;
    }

    modifier canMoveTreasureFounds(uint256 amount) {
        _checkTreasureOperation(TreasureOperationType.TransferToken, TREASURY_SECRETARY, amount);
        _;
    }

    modifier canAppointSecretary() {
        if (!_hasRole(TREASURY_SECRETARY_MANAGER)) {
            revert TreasuryUnauthorizedSecretaryAppointment(_msgSender());
        }
        _;
    }

    function _defineTreasureOnce(address treasureAccount) internal onlyOwner {
        if (treasureAccount == address(0)) {
            revert TreasureInvalidAddress(treasureAccount);
        }

        if (_treasure != address(0)) {
            revert TreasureAlreadyDefined(_treasure, treasureAccount);
        }

        _treasure = treasureAccount;
    }

    function _checkTreasure() private view {
        if (_treasure == address(0)) {
            revert UndefinedTreasure();
        }
    }

    function _checkAmount(uint256 amount) private view {
        if (amount == 0) {
            revert TreasuryOperationInvalidAmount(_msgSender(), amount);
        }
    }

    function _checkOprMaxAmount(TreasureOperationType oprType, uint256 amount) private view {
        bytes32 role = _getRole();
        uint256 operationMaxAmount = _treasuryOperationAmountLimits[role].maxAmount[oprType];

        if (operationMaxAmount != 0 && amount > operationMaxAmount) {
            revert TreasuryOperationExceedsLimitPerTransaction(
                _msgSender(), role, amount, oprType, operationMaxAmount
            );
        }
    }

    function _hasRole(bytes32 role) private view returns (bool) {
        return hasRole(role, _msgSender());
    }

    function _getRole() private view returns (bytes32) {
        if (_hasRole(TREASURY_TREASURER)) {
            return TREASURY_TREASURER;
        }
        else if (_hasRole(TREASURY_SECRETARY)) {
            return TREASURY_SECRETARY;
        }

        return 0;
    }

    function _hasMinimumRole(bytes32 minimumRole) private view returns(bool) {
        bytes32 role = _getRole();

        bool hasMinimumRole = (minimumRole == TREASURY_TREASURER)
            ? role == TREASURY_TREASURER
            : (minimumRole == TREASURY_SECRETARY)
                ? role == TREASURY_TREASURER
                    || role == TREASURY_SECRETARY
                : false;

        return hasMinimumRole;
    }

    function _checkTreasureOperation(
        TreasureOperationType oprType, bytes32 minimumRole, uint256 amount
    ) private view {
        _checkTreasure();
        _checkAmount(amount);

        if (!_hasMinimumRole(minimumRole)) {
            revert TreasuryUnauthorizedTreasureOperation(_msgSender(), oprType, minimumRole, amount);
        }

        _checkOprMaxAmount(oprType, amount);
    }

    function treasure() public view returns(address) {
        _checkTreasure();
        return _treasure;
    }

    function appointTreasurer(address treasurer) external onlyOwner {
        if (treasurer == address(0)) {
            revert TreasuryInvalidTresurer(treasurer);
        }

        grantRole(TREASURY_TREASURER, treasurer);
        grantRole(TREASURY_SECRETARY_MANAGER, treasurer);

        emit TreasurerAppointed(treasurer);
    }

    function dismissTreasurer(address treasurer) external onlyOwner {
        if (treasurer == address(0)) {
            revert TreasuryInvalidTresurer(treasurer);
        }

        revokeRole(TREASURY_TREASURER, treasurer);
        revokeRole(TREASURY_SECRETARY_MANAGER, treasurer);

        emit TreasurerDismissed(treasurer);
    }

    function appointSecretary(address secretary) external canAppointSecretary {
        if (secretary == address(0)) {
            revert TreasuryInvalidSecretary(secretary);
        }

        grantRole(TREASURY_SECRETARY, secretary);

        emit SecretaryAppointed(secretary);
    }

    function dismissSecretary(address secretary) external canAppointSecretary {
        if (secretary == address(0)) {
            revert TreasuryInvalidSecretary(secretary);
        }

        revokeRole(TREASURY_SECRETARY, secretary);

        emit SecretaryDismissed(secretary);
    }
}
