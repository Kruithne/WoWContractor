--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	Contracts.lua - Defines pre-made contracts for players.
]]--
do
    --[[ Global References ]]--
    local pairs = pairs;
    local _C = _Contractor;

    --[[ Contract Data ]]--
    local data = {
        [44237] = { -- Maegan Tillman, Pig and Whistle, Stormwind City
            { targets = {822}, count = 5, textFull = _C.ContractElwynnBearsFull, textShort = _C.ContractElwynnBearsShort },
            { targets = {474}, count = 5, textFull = _C.ContractElwynnWizardsFull, textShort = _C.ContractElwynnWizardsShort },
        }
    };

    -- Iterate the data set and add each contract.
    for npcID, contracts in pairs(data) do
        for index, data in pairs(contracts) do
            _C.AddStaticContract(npcID, data);
        end
    end
end
