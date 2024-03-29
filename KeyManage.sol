pragma solidity ^0.5.4;
import "./VPIEternalStorage.sol";
import "./ConstantsValue.sol";

contract KeyManage is ConstantsValue {
    EternalStorage private Database;

    constructor(address _EternalStorageAddress) public {
        Database = EternalStorage(_EternalStorageAddress);

        bytes32 _key = getKey(tx.origin, "ADMIN", getAccessKey());
        Database.set(_key, 1);
    }

    modifier canAccess() {
        bool access = keyHasRole(tx.origin, "ADMIN", 1);
        if (!access) revert();
        _;
    }

    function getRole(bytes32 _key) private view returns (uint256) {
        uint256 role = Database.getUintValue(_key);
        return role;
    }

    function getRole(address user, string memory code)
        public
        view
        returns (uint256)
    {
        bytes32 _key = getKey(user, code, getAccessKey());
        uint256 role = getRole(_key);

        return role;
    }

    function addRole(
        address user,
        string memory code,
        uint256 role
    ) public canAccess {
        bytes32 key = getKey(user, code, getAccessKey());
        addRole(key, role);
    }

    function addRole(bytes32 key, uint256 role) private {
        uint256 accessRole = getRole(key);

        require(accessRole == 0, "Key already exists");

        Database.set(key, role);
    }

    function editRole(
        address user,
        string memory code,
        uint256 role
    ) public canAccess {
        bytes32 key = getKey(user, code, getAccessKey());
        editRole(key, role);
    }

    function editRole(bytes32 key, uint256 role) private {
        Database.set(key, role);
    }

    function removeRole(address user, string memory code) public canAccess {
        bytes32 key = getKey(user, code, getAccessKey());
        removeRole(key);
    }

    function removeRole(bytes32 key) private {
        uint256 role = getRole(key);

        require(role != 0, "Key not found");

        Database.set(key, uint256(0));
    }

    function keyHasRole(
        address user,
        string memory code,
        uint256 role
    ) public view returns (bool) {
        bytes32 key = getKey(user, code, getAccessKey());

        bool success = keyHasRole(key, role);
        return success;
    }

    function keyHasRole(bytes32 key, uint256 role) private view returns (bool) {
        uint256 _role = Database.getUintValue(key);
        if (_role == 0) return false;
        return _role <= role;
    }
}
