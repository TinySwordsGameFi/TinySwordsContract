pragma solidity ^0.8.9;

interface ITSCoin {
    function mint(address user, uint256 money) external;

    function burn(address user, uint256 coins) external;
}

contract TS {
    struct Tribe {
        uint256 money;
        uint256 money2;
        uint256 money3;
        uint256 timestamp;
        address ref;
        uint256 refs;
        uint256 refs2;
        uint256 refs3;
        uint256 refMoney;
        uint256 woodman;
        uint256 farmer;
        uint256 hunter;
        uint256 miner;
        uint256 fighter;
    }

    struct StakingInfo {
        uint256 woodmanTime;
        uint256 farmerTime;
        uint256 hunterTime;
        uint256 minerTime;
        uint256 fighterTime;
        uint256 woodmans;
        uint256 farmers;
        uint256 hunters;
        uint256 miners;
        uint256 fighters;
    }

    mapping(address => Tribe) public tribe;
    mapping(address => StakingInfo) public stakingInfo;
    uint256 public totalVillager;
    uint256 public totalTribe;
    ITSCoin public constant TSCoin = ITSCoin(0xCB01343a4f7B9A838b6046029814b39d90514A4C);

    function buyVillager(address ref, uint256 woodman, uint256 farmer, uint256 hunter, uint256 miner, uint256 fighter) external {
        require(woodman >= 0 && farmer >= 0 && hunter >= 0 && miner >= 0 && fighter >= 0, "Must be a natural number");
        address user = msg.sender;
        uint256 coins = woodman * 500 + farmer * 1500 + hunter * 4500 + miner * 13500 + fighter * 40500;
        TSCoin.burn(user, coins);
        if (tribe[user].timestamp == 0) {
            if (tribe[ref].timestamp != 0) {
                tribe[user].money += coins * 3;
                tribe[user].ref = ref;
                tribe[ref].refs++;
                address ref2 = tribe[ref].ref;
                if (tribe[ref2].timestamp != 0) {
                    tribe[ref2].refs2++;
                    address ref3 = tribe[ref2].ref;
                    if (tribe[ref3].timestamp != 0) {
                        tribe[ref3].refs3++;
                    }
                }
            }
            totalTribe++;
            tribe[user].timestamp = block.timestamp;
        }
        totalVillager += woodman + farmer + hunter + miner + fighter;
        tribe[user].woodman += woodman;
        tribe[user].farmer += farmer;
        tribe[user].hunter += hunter;
        tribe[user].miner += miner;
        tribe[user].fighter += fighter;
        ref = tribe[user].ref;
        if (ref != address(0)) {
            tribe[ref].refMoney += coins * 7;
            tribe[ref].money += coins * 7;
            address ref2 = tribe[ref].ref;
            if (ref2 != address(0)) {
                tribe[ref2].refMoney += coins * 3;
                tribe[ref2].money += coins * 3;
                address ref3 = tribe[ref2].ref;
                if (ref3 != address(0)) {
                    tribe[ref3].refMoney += coins * 1;
                    tribe[ref3].money += coins * 1;
                }
            }
        }
    }

    function unStaking(uint256 woodman, uint256 farmer, uint256 hunter, uint256 miner, uint256 fighter) external {
        require(woodman >= 0 && farmer >= 0 && hunter >= 0 && miner >= 0 && fighter >= 0, "Must be a natural number");
        address user = msg.sender;

        if (woodman > 0) {
            if (stakingInfo[user].woodmans >= woodman) {
                stakingInfo[user].woodmans -= woodman;
                tribe[user].woodman += woodman;
            }
        }
        if (farmer > 0) {
            if (stakingInfo[user].farmers >= farmer) {
                stakingInfo[user].farmers -= farmer;
                tribe[user].farmer += farmer;
            }
        }
        if (hunter > 0) {
            if (stakingInfo[user].hunters >= hunter) {
                stakingInfo[user].hunters -= hunter;
                tribe[user].hunter += hunter;
            }
        }
        if (miner > 0) {
            if (stakingInfo[user].miners >= miner) {
                stakingInfo[user].miners -= miner;
                tribe[user].miner += miner;
            }
        }
        if (fighter > 0) {
            if (stakingInfo[user].fighters >= fighter) {
                stakingInfo[user].fighters -= fighter;
                tribe[user].fighter += fighter;
            }
        }
    }

    function stakingVillager(uint256 woodman, uint256 farmer, uint256 hunter, uint256 miner, uint256 fighter) external {
        require(woodman >= 0 && farmer >= 0 && hunter >= 0 && miner >= 0 && fighter >= 0, "Must be a natural number");
        address user = msg.sender;

        if (woodman > 0) {
            if (tribe[user].woodman >= woodman) {
                tribe[user].woodman -= woodman;
                stakingInfo[user].woodmanTime = block.timestamp;
                stakingInfo[user].woodmans += woodman;
            }
        }
        if (farmer > 0) {
            if (tribe[user].farmer >= farmer) {
                tribe[user].farmer -= farmer;
                stakingInfo[user].farmerTime = block.timestamp;
                stakingInfo[user].farmers += farmer;
            }
        }

        if (hunter > 0) {
            if (tribe[user].hunter >= hunter) {
                tribe[user].hunter -= hunter;
                stakingInfo[user].hunterTime = block.timestamp;
                stakingInfo[user].hunters += hunter;
            }
        }

        if (miner > 0) {
            if (tribe[user].miner >= miner) {
                tribe[user].miner -= miner;
                stakingInfo[user].minerTime = block.timestamp;
                stakingInfo[user].miners += miner;
            }
        }
        if (fighter > 0) {
            if (tribe[user].fighter >= fighter) {
                tribe[user].fighter -= fighter;
                stakingInfo[user].fighterTime = block.timestamp;
                stakingInfo[user].fighters += fighter;
            }
        }
    }

    function withdrawMoney() external {
        address user = msg.sender;
        uint256 money = tribe[user].money;
        require(money > 0, "Zero money");
        tribe[user].money = 0;
        tribe[user].money3 += money;
        TSCoin.mint(user, money);
    }

    function collectMoney() external {
        address user = msg.sender;
        syncTribe(user);
        tribe[user].money += tribe[user].money2;
        tribe[user].money2 = 0;
    }

    function syncTribe(address user) internal {
        uint256 timestamp = tribe[user].timestamp;
        require(timestamp > 0, "User is not registered");

        if (stakingInfo[user].farmers > 0) {
            tribe[user].money2 += (block.timestamp/3600 - stakingInfo[user].farmerTime / 3600) * 50 * stakingInfo[user].farmers;
            stakingInfo[user].farmerTime = block.timestamp;
        }

        if (stakingInfo[user].woodmans > 0) {
            tribe[user].money2 += (block.timestamp/3600 - stakingInfo[user].woodmanTime / 3600) * 150 * stakingInfo[user].woodmans;
            stakingInfo[user].woodmanTime = block.timestamp;
        }

        if (stakingInfo[user].hunters > 0) {
            tribe[user].money2 += (block.timestamp/3600 - stakingInfo[user].hunterTime / 3600) * 625 * stakingInfo[user].hunters;
            stakingInfo[user].hunterTime = block.timestamp;
        }

        if (stakingInfo[user].miners > 0) {
            tribe[user].money2 += (block.timestamp/3600 - stakingInfo[user].minerTime / 3600) * 1600 * stakingInfo[user].miners;
            stakingInfo[user].minerTime = block.timestamp;
        }

        if (stakingInfo[user].fighters > 0) {
            tribe[user].money2 += (block.timestamp/3600 - stakingInfo[user].fighterTime / 3600) * 5600 * stakingInfo[user].fighters;
            stakingInfo[user].fighterTime = block.timestamp;
        }
    }
}
