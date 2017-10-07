--[[
	Contractor (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.

	https://github.com/Kruithne/WoWContractor

	locale/enUS.lua - Provides English (default) localization strings.
]]--
do
    _Contractor.ApplyLocalization({
        AddonName = "Contractor", -- Do Not Translate
        VersionLoaded = "%s version v%s has been loaded.",
        GossipLookingForContract = "I'm looking for a contract.",
        GossipContractComplete = "I've finished the contract.",
        GossipContractProgress = "How am I doing on the contract?",
        GossipContractAbandon = "I'd like to abandon my current contract.",
        GossipContractOkay = "Okay, got it.",
        GossipAcceptedText = "Very well,\n\nYour task is to %s.\n\nOnce you've completed this, return to me and I shall grant you a reward.\n\nYou can still accept contracts from other people, and if you need to check how you're doing with this one you can ask me at any point.\n\nShould you lose your courage, just let me know and you can abandon the contract.",
        GossipProgressText = "Hmm,\n\nBy my records, you have %d %s out of the %d needed.",
        GossipAbandonConfirm = "Are you sure you want to abandon your current contract? Any progress you've made on it will be lost.",
        GossipAbandonConfirmOption = "I'm sure, abandon the contract.",
        GossipAbandonAbortOption = "Actually, I've changed my mind.",

        ContractElwynnBearsFull = "slay %d bears roaming the forests of Elwynn",
        ContractElwynnBearsShort = "Bears slain",
        ContractElwynnWizardsFull = "kill %d rogue wizards operating in Elwynn Forest",
        ContractElwynnWizardsShort = "Rogue Wizards killed",
    });
end
