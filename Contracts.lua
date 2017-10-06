--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contracts.lua - Defines pre-made contracts for players.
]]--
do
    local pairs = pairs;
    local AddStaticContract = _Contractor.AddStaticContract;
    local data = {
        [44237] = {
            ["ELW_BEARS"] = { targets = {822}, count = 5 },
            ["ELW_WIZARDS"] = { targets = {474}, count = 5 }
        }
    };

    -- Iterate the data set and add each contract.
    for npcID, contracts in pairs(data) do
        for contractID, data in pairs(contracts) do
            AddStaticContract(npcID, contractID, data);
        end
    end
end
