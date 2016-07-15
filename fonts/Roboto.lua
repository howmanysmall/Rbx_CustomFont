--[[
	@Font Roboto
	@Sizes {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8}
	@Author Christian Robertson
	@Link https://www.fontsquirrel.com/fonts/list/foundry/christian-robertson
--]]

local module = {};

module.atlases = {
    [1]  = "rbxassetid://392953276";
    [2]  = "rbxassetid://392953280";
    [3]  = "rbxassetid://392953283";
    [4]  = "rbxassetid://392953290";
    [5]  = "rbxassetid://392953287";
    [6]  = "rbxassetid://392953282";
    [7]  = "rbxassetid://392953288";
    [8]  = "rbxassetid://392953301";
    [9]  = "rbxassetid://392953307";
    [10] = "rbxassetid://392953298";
    [11] = "rbxassetid://392953303";
    [12] = "rbxassetid://392953305";
    [13] = "rbxassetid://392953309";
    [14] = "rbxassetid://392953313";
    [15] = "rbxassetid://392953315";
    [16] = "rbxassetid://392953317";
    [17] = "rbxassetid://393140459";
    [18] = "rbxassetid://393140480";
    [19] = "rbxassetid://393140472";
    [20] = "rbxassetid://393140476";
    [21] = "rbxassetid://393140483";
    [22] = "rbxassetid://393140490";
    [23] = "rbxassetid://393140486";
    [24] = "rbxassetid://393140499";
    [25] = "rbxassetid://393140510";
    [26] = "rbxassetid://392953353";
    [27] = "rbxassetid://393140503";
    [28] = "rbxassetid://392953351";
    [29] = "rbxassetid://392953357";
    [30] = "rbxassetid://392953363";
    [31] = "rbxassetid://392953360";
    [32] = "rbxassetid://392953362";
    [33] = "rbxassetid://393055828";
    [34] = "rbxassetid://392953667";
    [35] = "rbxassetid://393055824";
    [36] = "rbxassetid://392953669";
    [36] = "rbxassetid://393055840";
    [37] = "rbxassetid://392953672";
    [37] = "rbxassetid://393055843";
    [38] = "rbxassetid://393055845";
    [39] = "rbxassetid://393055854";
    [40] = "rbxassetid://393055846";
    [41] = "rbxassetid://393055853";
    [42] = "rbxassetid://393055869";
    [43] = "rbxassetid://393055875";
    [44] = "rbxassetid://393055866";
    [45] = "rbxassetid://393055873";
    [46] = "rbxassetid://393055880";
    [47] = "rbxassetid://393055878";
    [48] = "rbxassetid://393140507";
    [49] = "rbxassetid://393140512";
    [50] = "rbxassetid://393140514";
    [51] = "rbxassetid://393055887";

    -- Accents start here!
        [101] = "rbxassetid://454351749";
        [83] = "rbxassetid://454351747";
        [81] = "rbxassetid://454334344";
        [99] = "rbxassetid://454334338";
        [98] = "rbxassetid://454334335";
        [97] = "rbxassetid://454334331";
        [96] = "rbxassetid://454334328";
        [79] = "rbxassetid://454334324";
        [93] = "rbxassetid://454334320";
        [94] = "rbxassetid://454334316";
        [92] = "rbxassetid://454334302";
        [77] = "rbxassetid://454334298";
        [90] = "rbxassetid://454334296";
        [89] = "rbxassetid://454334291";
        [88] = "rbxassetid://454334286";
        [75] = "rbxassetid://454334282";
        [86] = "rbxassetid://454334280";
        [85] = "rbxassetid://454334278";
        [100] = "rbxassetid://454334272";
        [91] = "rbxassetid://454334270";
        [84] = "rbxassetid://454334265";
        [74] = "rbxassetid://454334263";
        [102] = "rbxassetid://454334257";
        [71] = "rbxassetid://454334255";
        [72] = "rbxassetid://454334251";
        [80] = "rbxassetid://454334247";
        [78] = "rbxassetid://454334244";
        [70] = "rbxassetid://454334241";
        [87] = "rbxassetid://454334235";
        [76] = "rbxassetid://454334234";
        [73] = "rbxassetid://454334232";
        [95] = "rbxassetid://454334227";
        [82] = "rbxassetid://454334225";
        [69] = "rbxassetid://454332428";
        [68] = "rbxassetid://453576779";
        [67] = "rbxassetid://453398805";
        [66] = "rbxassetid://453392538";
        [65] = "rbxassetid://453365455";
        [64] = "rbxassetid://453354136";
        [63] = "rbxassetid://452871064";
        [62] = "rbxassetid://450238778";
        [61] = "rbxassetid://449480067";
        [59] = "rbxassetid://449392088";
        [60] = "rbxassetid://449309595";
        [58] = "rbxassetid://449251185";
        [57] = "rbxassetid://449219940";
        [56] = "rbxassetid://449214327";
        [55] = "rbxassetid://449211965";
        [54] = "rbxassetid://449208078";
        [53] = "rbxassetid://449205601";
        [52] = "rbxassetid://449198908";};

module.font = {
	information = {
		family = "Roboto";
		styles = {"Black", "Black Italic", "Bold", "Bold Italic", "Italic", "Light", "Light Italic", "Medium", "Medium Italic", "Regular", "Thin", "Thin Italic"};
		sizes = {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8};
		useEnums = true;
	};
	styles = {
            Black = require(script.Black);
            ["Black Italic"] = require(script.BlackItalic);
            Bold = require(script.Bold);
            ["Bold Italic"] = require(script.BoldItalic);
            Italic = require(script.Italic);
            Light = require(script.Light);
            ["Light Italic"] = require(script.LightItalic);
            Medium = require(script.Medium);
            ["Medium Italic"] = require(script.MediumItalic);
            Regular = require(script.Regular);
            Thin = require(script.Thin);
            ["Thin Italic"] = require(script.ThinItalic);
	};
};



return module;
