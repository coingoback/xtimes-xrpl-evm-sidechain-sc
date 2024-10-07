// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract TreasuryOwnable is Ownable, AccessControl {
    address private _treasure;

    /** @dev Can issue, pause, transfer and burn tokens directly from/to the treasure */
    bytes32 public constant TREASURE_TREASURER_ROLE = keccak256("TREASURY_TREASURER");

    /** @dev Can transfer and burn directly from treasure */
    bytes32 public constant TREASURE_SECRETARY_ROLE = keccak256("TREASURY_SECRETARY");

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

    constructor() Ownable(_msgSender()) {}

    modifier canIssue(uint256 amount) {
        _checkTreasureOperation(TreasureOperationType.IssueToken, TREASURE_TREASURER_ROLE, amount);
        _;
    }

    modifier canBurn(uint256 amount) {
        _checkTreasureOperation(TreasureOperationType.BurnToken, TREASURE_SECRETARY_ROLE, amount);
        _;
    }

    modifier canMoveTreasureFounds(uint256 amount) {
        _checkTreasureOperation(TreasureOperationType.TransferToken, TREASURE_SECRETARY_ROLE, amount);
        _;
    }

    modifier canAppointSecretary() {
        address sender = _msgSender();
        if (sender != owner() && !hasRole(TREASURE_TREASURER_ROLE, sender)) {
            revert TreasuryUnauthorizedSecretaryAppointment(sender);
        }
        _;
    }

    function _defineTreasureOnce(address treasureAccount) private onlyOwner {
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
        if (_hasRole(TREASURE_TREASURER_ROLE)) {
            return TREASURE_TREASURER_ROLE;
        }
        else if (_hasRole(TREASURE_TREASURER_ROLE)) {
            return TREASURE_TREASURER_ROLE;
        }

        return 0;
    }

    function _hasMinimumRole(bytes32 minimumRole) private view returns(bool) {
        bytes32 role = _getRole();

        bool hasMinimumRole = (minimumRole == TREASURE_TREASURER_ROLE)
            ? role == TREASURE_TREASURER_ROLE
            : (minimumRole == TREASURE_SECRETARY_ROLE)
                ? role == TREASURE_TREASURER_ROLE
                    || role == TREASURE_SECRETARY_ROLE
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

    function appointTreasurer(address treasurer) public onlyOwner {
        if (treasurer == address(0)) {
            revert TreasuryInvalidTresurer(treasurer);
        }

        grantRole(TREASURE_TREASURER_ROLE, treasurer);

        emit TreasurerAppointed(treasurer);
    }

    function dismissTreasurer(address treasurer) public onlyOwner {
        if (treasurer == address(0)) {
            revert TreasuryInvalidTresurer(treasurer);
        }

        revokeRole(TREASURE_TREASURER_ROLE, treasurer);

        emit TreasurerDismissed(treasurer);
    }

    function appointSecretary(address secretary) public canAppointSecretary {
        if (secretary == address(0)) {
            revert TreasuryInvalidSecretary(secretary);
        }

        grantRole(TREASURE_SECRETARY_ROLE, secretary);

        emit SecretaryAppointed(secretary);
    }

    function dismissSecretary(address secretary) public canAppointSecretary {
        if (secretary == address(0)) {
            revert TreasuryInvalidSecretary(secretary);
        }

        revokeRole(TREASURE_SECRETARY_ROLE, secretary);

        emit SecretaryDismissed(secretary);
    }
}
