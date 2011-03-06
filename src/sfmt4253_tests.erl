%% @author Kenji Rikitake <kenji.rikitake@acm.org>
%% @author Mutsuo Saito
%% @author Makoto Matsumoto
%% @author Dan Gudmundsson
%% @doc SIMD-oriented Fast Mersenne Twister (SFMT) EUnit testing functions.
%% The module provides EUnit testing functions for the sfmt4253 module functions.
%% (for period ((2^4253) - 1))
%% @reference <a href="http://github.com/jj1bdx/sfmt-erlang">GitHub page
%% for sfmt-erlang</a>
%% @copyright 2010-2011 Kenji Rikitake and Kyoto University.
%% Copyright (c) 2006, 2007 Mutsuo Saito, Makoto Matsumoto and
%% Hiroshima University.

%% Copyright (c) 2010-2011 Kenji Rikitake and Kyoto University. All rights
%% reserved.
%%
%% Copyright (c) 2006,2007 Mutsuo Saito, Makoto Matsumoto and Hiroshima
%% University. All rights reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are
%% met:
%%
%%     * Redistributions of source code must retain the above copyright
%%       notice, this list of conditions and the following disclaimer.
%%     * Redistributions in binary form must reproduce the above
%%       copyright notice, this list of conditions and the following
%%       disclaimer in the documentation and/or other materials provided
%%       with the distribution.
%%     * Neither the names of the Hiroshima University and the Kyoto
%%       University nor the names of its contributors may be used to
%%       endorse or promote products derived from this software without
%%       specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
%% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
%% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-module(sfmt4253_tests).

-export([
	 test_speed/0
	 ]).

test_speed_rand_rec1(0, _, _) ->
    ok;
test_speed_rand_rec1(X, Q, I) ->
    {_, I2} = sfmt4253:gen_rand_list32(Q, I),
    test_speed_rand_rec1(X - 1, Q, I2).

test_speed_rand(P, Q) ->
    statistics(runtime),
    I = sfmt4253:init_gen_rand(1234),
    ok = test_speed_rand_rec1(P, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_sfmt_uniform_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_sfmt_uniform_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_sfmt_uniform_rec1([], X - 1, R, R, I);
test_speed_sfmt_uniform_rec1(Acc, X, Q, R, I) ->
    {F, I2} = sfmt4253:uniform_s(I),
    test_speed_sfmt_uniform_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_sfmt_uniform(P, Q) ->
    statistics(runtime),
    I = sfmt4253:seed(),
    ok = test_speed_sfmt_uniform_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_orig_uniform_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_orig_uniform_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_orig_uniform_rec1([], X - 1, R, R, I);
test_speed_orig_uniform_rec1(Acc, X, Q, R, I) ->
    {F, I2} = random:uniform_s(I),
    test_speed_orig_uniform_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_orig_uniform(P, Q) ->
    statistics(runtime),
    I = random:seed(),
    ok = test_speed_orig_uniform_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_rand_max_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_rand_max_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_rand_max_rec1([], X - 1, R, R, I);
test_speed_rand_max_rec1(Acc, X, Q, R, I) ->
    {F, I2} = sfmt4253:gen_rand32_max(10000, I),
    test_speed_rand_max_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_rand_max(P, Q) ->
    statistics(runtime),
    I = sfmt4253:init_gen_rand(1234),
    ok = test_speed_rand_max_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_orig_uniform_n_rec1(Acc, 0, _, _, _) ->
    lists:reverse(Acc),
    ok;
test_speed_orig_uniform_n_rec1(Acc, X, 0, R, I) ->
    lists:reverse(Acc),
    test_speed_orig_uniform_n_rec1([], X - 1, R, R, I);
test_speed_orig_uniform_n_rec1(Acc, X, Q, R, I) ->
    {F, I2} = random:uniform_s(10000, I),
    test_speed_orig_uniform_n_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_orig_uniform_n(P, Q) ->
    statistics(runtime),
    I = random:seed(),
    ok = test_speed_orig_uniform_n_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

%% @doc running speed test for 100 times of
%% 100000 calls for sfmt4253:gen_rand32/1, sfmt4253:uniform_s/1,
%% random:uniform_s/1, sfmt4253:gen_rand32_max/2, and random:uniform_s/2.

test_speed() ->
    io:format("{rand, sfmt_uniform, orig_uniform, rand_max, orig_uniform_n}~n~p~n",
	      [{test_speed_rand(100, 100000),
		test_speed_sfmt_uniform(100, 100000),
		test_speed_orig_uniform(100, 100000),
	        test_speed_rand_max(100, 100000),
		test_speed_orig_uniform_n(100, 100000)}
	      ]).

%% EUnit test functions

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

%% @doc gen_rand32 and gen_rand_float API tests

gen_rand_tests() ->
    I0 = sfmt4253:init_gen_rand(1234),
    {N1, I1} = sfmt4253:gen_rand32(I0),
    ?assert(is_integer(N1)),
    {N2, _I2} = sfmt4253:gen_rand32(I1),
    ?assert(is_integer(N2)),
    {F3, I3} = sfmt4253:gen_rand_float(I0),
    ?assert(is_float(F3)),
    {F4, _I4} = sfmt4253:gen_rand_float(I3),
    ?assert(is_float(F4)),
    {Outarray0, _I5} = sfmt4253:gen_rand_list_float(10, I0),
    ?assert(is_float(hd(Outarray0))),
    ?assertMatch(10, length(Outarray0)),
    {N6, I6} = sfmt4253:gen_rand32_max(10000, I0),
    ?assert(is_integer(N6)),
    ?assert(N6 < 10000),
    {N7, _I7} = sfmt4253:gen_rand32_max(10000, I6),
    ?assert(is_integer(N7)),
    ?assert(N7 < 10000).
    
test_rec1(0, Acc, RS) ->
     {lists:reverse(Acc), RS};
test_rec1(I, Acc, RS) ->
     {Val, RS2} = sfmt4253:gen_rand32(RS),
     test_rec1(I - 1, [Val | Acc], RS2).

%% @doc  Value tests of the first 10000 random numbers 
%%       initialized by init_gen_rand/1 by gen_rand_list32/2.

value_tests_1() ->
    {Refrand, _Refarray} = test_refval(),
    Int1 = sfmt4253:init_gen_rand(1234),
    {Outarray1, Int2} = sfmt4253:gen_rand_list32(10000, Int1),
    ?assertEqual(Refrand, lists:reverse(
			    lists:nthtail(10000 - length(Refrand),
					  lists:reverse(Outarray1)))),
    {Outarray2, _Int3} = sfmt4253:gen_rand_list32(10000, Int2),
    {Outarray3, RS4} = test_rec1(10000, [], {[], Int1}),
    ?assertEqual(Outarray3, Outarray1),
    {Outarray4, _RS5} = test_rec1(10000, [], RS4),
    ?assertEqual(Outarray4, Outarray2).

%% @doc  Value tests of the first 10000 random numbers 
%%       initialized by init_by_list32/1 by gen_rand_list32/2.

value_tests_2() ->
    {_Refrand, Refarray} = test_refval(),
    Int1 = sfmt4253:init_by_list32([16#1234, 16#5678, 16#9abc, 16#def0]),
    {Outarray1, Int2} = sfmt4253:gen_rand_list32(10000, Int1),
    ?assertEqual(Refarray,
		 lists:reverse(
		   lists:nthtail(10000 - length(Refarray),
				 lists:reverse(Outarray1)))),
    {Outarray2, _Int3} = sfmt4253:gen_rand_list32(10000, Int2),
    {Outarray3, RS4} = test_rec1(10000, [], {[], Int1}),
    ?assertEqual(Outarray3, Outarray1),
    {Outarray4, _RS5} = test_rec1(10000, [], RS4),
    ?assertEqual(Outarray4, Outarray2).

%% @doc simple testing function as used in EUnit

simple_test_() -> 
    [
     ?_assertMatch(ok, gen_rand_tests()),
     ?_assertMatch(ok, value_tests_1()),
     ?_assertMatch(ok, value_tests_2())
    ].

%% @doc test value definitions (as in SFMT.4253.out.txt)

test_refval() ->
    %% values taken from SFMT.4253.out.txt of SFMT-1.3.3
    Refrand = [
	       2527479900, 1368357778, 2663671614, 1404435254, 2699472814,
	       90613554, 184715818, 548052880, 3165295246, 3747208322,
	       1553584151, 4006205422, 686873885, 2973265227, 338288274,
	       840903586, 118479351, 2113933085, 2454705318, 4160313692,
	       258320158, 2069535581, 3111482672, 1808812962, 1061444454,
	       3414467438, 2429935983, 22860572, 1366710514, 3914109077,
	       431345992, 2592701388, 4278051019, 2953043318, 3980401588,
	       3881325187, 1564504370, 834859481, 3060669055, 1337040117,
	       550209132, 3820737668, 730655732, 2134953975, 3660203170,
	       3949145665, 3089869106, 2462203695, 2517266551, 127768183,
	       1458427300, 968958252, 4160350980, 197127760, 1732124944,
	       94014226, 1531549192, 113002317, 677141155, 287564565,
	       4257548747, 4292783614, 2751209905, 1752328661, 3243295598,
	       923465190, 2894924894, 2740856471, 4055981426, 473191365,
	       908700607, 422974067, 469692967, 757624668, 3432965499,
	       1831360524, 1428429851, 2483671900, 1390761012, 3810347628,
	       629385285, 3930097219, 2052308184, 4168023275, 388853205,
	       3768997406, 3330670734, 2055104098, 1106186192, 1933427225,
	       2226099390, 3454131780, 2957350718, 3823231548, 1817256940,
	       4215997696, 871018468, 3167946875, 2754001419, 236180895,
	       3233859043, 2373649380, 1292426575, 3607842917, 2701992479,
	       148610584, 3264599936, 1393846909, 2499792154, 736433790,
	       3157082272, 2880794545, 994805876, 534093287, 197116649,
	       851477442, 2146732429, 2183911085, 894942183, 832710978,
	       3901770969, 3359969465, 882420449, 2241823448, 1492166544,
	       3992403187, 597213559, 1969755128, 426287380, 4061611377,
	       1687362889, 1946092277, 4125751232, 2340826817, 1023094896,
	       2453795243, 1016397383, 2066650694, 2829818145, 4240397962,
	       1677661629, 2003846114, 809330389, 3806142170, 201244744,
	       2566284206, 571778809, 3414471796, 1048918104, 1729550124,
	       2292438588, 1801879825, 595036908, 4103514229, 3405015679,
	       529495538, 3896500793, 2584783745, 2054273460, 3846917154,
	       751616450, 2298779837, 744937613, 2655442675, 3129294927,
	       2616177535, 109487464, 2084297522, 3149948545, 146626839,
	       141416550, 219840792, 198827062, 180973611, 1821886528,
	       4017582600, 1052759440, 1015031793, 991373390, 508903622,
	       2182588526, 3077049840, 521761680, 1545070310, 3957281201,
	       171128523, 1147783672, 2533170216, 3838957621, 1237736619,
	       552147257, 1556527506, 1515560982, 2308626297, 3482690030,
	       2879183618, 2457518673, 1850653525, 3553910637, 2860551374,
	       3434228513, 1731298733, 3588698536, 806858307, 3613883468,
	       523208067, 3414202318, 3393689440, 2353240359, 4127122117,
	       1831732142, 847638871, 1619828199, 2124696779, 3990800766,
	       3933888641, 3182339244, 3360495242, 3916631449, 2657507170,
	       3148012381, 1372045589, 409909367, 1928161391, 2430406320,
	       3344152345, 3461790387, 2879089167, 187732582, 97521756,
	       4177685510, 300969389, 3888421994, 3639345081, 1296034375,
	       3343230691, 2614990524, 201084198, 1280068382, 2992697415,
	       2115717691, 1189674758, 87443442, 1108849849, 3999298855,
	       551654632, 2843181712, 1438915708, 634243182, 2011185720,
	       608579410, 897151476, 3827358299, 441056267, 3958241396,
	       2377342291, 3825269665, 520209674, 3742883636, 3483477678,
	       429112330, 1063433049, 460156961, 1983998260, 3131916395,
	       3825314043, 1541860318, 505894702, 1118748714, 2750017164,
	       1318839272, 2705734886, 1348131583, 1671597785, 327049114,
	       2349038687, 3191898447, 65778986, 309294146, 4210524532,
	       954190761, 2796234546, 760913068, 1495807915, 719879568,
	       1098025642, 2507498292, 1989256114, 3199663249, 1687943539,
	       2797834855, 2875620767, 3049687385, 675610541, 2679231804,
	       1993787755, 103928858, 270737000, 2250936910, 1319674681,
	       3533390078, 2940559205, 3485860854, 1971895540, 494103928,
	       229873064, 1674251374, 3656511507, 1613711330, 1864093473,
	       3380224706, 2579813873, 1443886615, 553363027, 321798783,
	       343406389, 3588518585, 2027235001, 3491435871, 944912015,
	       1291890419, 763467230, 1301595200, 35530017, 1654917296,
	       2369528163, 43914463, 3385342605, 1519096256, 1160702704,
	       918487363, 2675524986, 2527817177, 1370542519, 2651742660,
	       2103037069, 1397939248, 264689110, 1413288205, 4004778218,
	       3299683988, 2841441176, 3598691083, 2182457567, 4054937081,
	       1066677974, 434982562, 1000338728, 2872338526, 3178007830,
	       112950674, 3265963247, 1078618426, 4136037652, 1802343389,
	       3054995837, 2634801100, 3576860529, 2756572027, 163670376,
	       2755164619, 3193086267, 3523741517, 2787825626, 3599211537,
	       3179624644, 3877008080, 2628341823, 3637377170, 4088700641,
	       2241341851, 2170453568, 193416186, 3372714382, 2794968447,
	       935329275, 996794956, 2916776696, 613865948, 2342638185,
	       620153472, 293440707, 3098925541, 3075946626, 3105163113,
	       2278427178, 2512248278, 3302195243, 1901360844, 341805416,
	       1498812479, 1022193034, 2730690487, 1608087974, 3769133791,
	       3085978560, 2569008479, 4163889308, 1373206796, 2318025416,
	       3851861687, 3012946747, 3977347475, 364722855, 2611302503,
	       4115709997, 78751760, 1281200331, 907864348, 1360886565,
	       1264593706, 2195635559, 1140394436, 1250223897, 76307824,
	       3678248796, 1596987024, 1463275883, 3347064538, 2245531442,
	       3000401995, 1424992573, 3512991755, 2510621610, 1721715256,
	       3075463170, 1466887879, 1999485116, 3962926634, 3870497011,
	       1751227678, 705057364, 1443520104, 2059482087, 3250691665,
	       3255166375, 1569067129, 3412844722, 3098977431, 2792159953,
	       2395673009, 3857642389, 1178307671, 2243727662, 3864522806,
	       3675533812, 2816048058, 1312820066, 3479095187, 2480595183,
	       2835049824, 3561740422, 3174217287, 416749385, 2139285735,
	       3821231700, 3329469401, 3091148385, 3510293280, 4191591727,
	       868224009, 2963941189, 4197718379, 3532559426, 1904090497,
	       1054636757, 813484583, 2750528848, 2712557992, 652666704,
	       1883222671, 4050435510, 1330436237, 2596765439, 300221336,
	       2181019682, 2979671327, 2514204653, 649224002, 342470286,
	       1851796018, 1300049431, 580587812, 1304252851, 3522677854,
	       1923755784, 556752185, 1914802797, 3654065680, 2752469800,
	       1726881082, 2250771284, 2135743124, 1830931411, 1469151786,
	       2104783727, 478155961, 1789588437, 739862484, 3135185315,
	       3386692983, 796221342, 3824201775, 774903840, 2539841190,
	       1798701707, 3156002374, 1557540949, 2038233868, 3369775005,
	       1967992094, 2352432999, 1754555210, 3383598210, 912042820,
	       1556344175, 2063567860, 3141410825, 3725100803, 935008972,
	       2420154214, 229384961, 932794923, 3121147627, 3677397520,
	       2030936421, 3783938574, 1056242163, 1094152240, 3130795881,
	       2212578528, 3650393830, 3763562182, 2941501937, 891356726,
	       3480329562, 2001363572, 3650716087, 2039712773, 2082265319,
	       3897556400, 2306486314, 794776544, 2658262370, 1205963556,
	       1244950749, 4068472397, 2316768749, 570442349, 597720630,
	       2389394507, 3094855718, 2509408387, 3458849306, 4003913153,
	       1606513088, 3682030133, 1351428839, 1329052705, 756713129,
	       3228203269, 2549330089, 1003597149, 815801656, 2935040849,
	       2126394226, 1966835343, 2123147961, 1100473787, 3508260126,
	       1347682278, 1813807731, 4087504287, 4274225369, 1233072466,
	       3982558179, 2182729378, 3788359817, 455938583, 107595104,
	       2183482541, 349724043, 3170305794, 1478463324, 3535450698,
	       2266873512, 1125200363, 1782202842, 562451765, 659545839,
	       3205089880, 1007748157, 1332259119, 2190756187, 2498360841,
	       1821141260, 2384457148, 3597604326, 2466625944, 3444958869,
	       2393658085, 3021642990, 3653781223, 988709427, 3343088257,
	       2542070759, 3030195976, 3201593233, 1146775076, 91189100,
	       937553383, 2253494027, 2923147891, 2964305654, 3687677728,
	       215864044, 1165902544, 3094419018, 1084293644, 3755627654,
	       4240346365, 2634668923, 3266634895, 459317309, 2448760566,
	       285022386, 1188948452, 2910236783, 2785682666, 1232664118,
	       1696483321, 260914322, 1643952881, 1205118871, 625088862,
	       2895045934, 2361165720, 3685846715, 342173372, 1277134079,
	       436664487, 3913210554, 3853335638, 3294636303, 897284118,
	       80550011, 35785936, 734063644, 3331155243, 3040972843,
	       2825628859, 1587205482, 2916119016, 1453645622, 29066455,
	       3674104445, 3856300201, 3910466588, 2305622298, 2500902145,
	       1471525683, 1665091699, 122696731, 438232290, 1485481363,
	       3134096607, 582664744, 36553553, 2555071952, 2875800128,
	       3558076452, 2341670027, 1048189476, 3448631571, 3105098020,
	       2836116166, 1164096049, 3336285606, 1777820482, 3259731819,
	       2535236186, 2173206310, 2141664756, 1795309580, 2712514906,
	       839414197, 3515333131, 3456768398, 894724664, 152591334,
	       3828470515, 101544558, 3139903673, 1758740316, 3655835928,
	       283689183, 1191066662, 1645801598, 2513632659, 2641101384,
	       3242370052, 3750378668, 1209952866, 3622825606, 3916290440,
	       2462296242, 3979411843, 2566629928, 1703841226, 3580800515,
	       2835163070, 800968534, 4126472075, 1336809651, 1698066670,
	       2583945033, 3719656938, 4161420199, 333983592, 3012713349,
	       2215029854, 3459379580, 3989216021, 3909381318, 3299172785,
	       377164461, 2190647378, 3773598435, 1082059749, 688217589,
	       3202128248, 1309168765, 2186797462, 893982067, 3808151150,
	       3750218766, 3488505749, 2160698729, 175659562, 366321575,
	       244537428, 709975671, 2243085387, 2437312200, 4072237343,
	       2793242070, 895851642, 987225785, 1918724975, 2286944600,
	       426287935, 987266265, 1518170331, 2787455281, 1808098392,
	       3384283435, 396002370, 3092824209, 3925958672, 1766217507,
	       283368391, 3162646348, 2985035730, 2837362361, 2168498198,
	       1429383440, 632822315, 3899799712, 1362373986, 3513820808,
	       2093651918, 2842493476, 4157113475, 684687567, 2908504190,
	       1879244483, 3704911505, 342871386, 1801214563, 1217345650,
	       3918483325, 1656942815, 1165618293, 1833497946, 3890213046,
	       2613428343, 1994103566, 2428507209, 2820676607, 2180335657,
	       1346479967, 1639143184, 4139533466, 1909445436, 3639600424,
	       4126977421, 2181979647, 811910263, 365549549, 3705120026,
	       808002836, 455149150, 1807086335, 2130995526, 4108275506,
	       1266847062, 4061326824, 2349396929, 3915985329, 1783849271,
	       905837971, 2683630735, 1800744620, 3875631925, 2252142673,
	       3251456840, 1459039165, 2833099474, 3531992522, 3710388286,
	       2190951573, 3354562341, 3268151049, 1184967222, 4195586075,
	       684446072, 2608178903, 2819665960, 3088369994, 2748683558,
	       1704439164, 4223437573, 1436190950, 4278853819, 3091164007,
	       1078378076, 723311767, 587703477, 3851946555, 3697804869,
	       4160379401, 2106953594, 593626618, 128041410, 4286706683,
	       2003531224, 1330231761, 2384455624, 1159174223, 1183759240,
	       218042236, 3850479175, 897884664, 2599517199, 3299195163,
	       1142309209, 339715569, 1115023699, 4248957598, 4175318311,
	       814230681, 3810578707, 1621592119, 3753479739, 2769366523,
	       2739541076, 3336778504, 2762821764, 425111024, 248054828,
	       302670898, 1344961520, 2877121830, 60326824, 3038819906,
	       2130084958, 3806365850, 1934968383, 2737798910, 2477223327,
	       1787404583, 4215091681, 3785408410, 889455514, 42797744,
	       962836281, 393066514, 3660403389, 1818627315, 1810946116,
	       3051684939, 1522629715, 2052877416, 1991288115, 317781593,
	       3953883323, 1889817433, 666448014, 1795497776, 1035321190,
	       3341408107, 938679669, 3586178906, 1816245957, 2643186312,
	       1189583008, 626879504, 2847556591, 1667291872, 931370811,
	       4119804642, 1282359131, 121925540, 414885461, 1990063976,
	       867354577, 2817097111, 668512758, 301590583, 1495974696,
	       3023244186, 675868526, 4291773200, 1659882362, 3340006089,
	       3053343330, 135103191, 1693243673, 146669000, 2312300071,
	       1615088906, 2568797318, 861836502, 3760445871, 356249917,
	       3258909047, 1935024562, 2856523904, 1272143201, 1814325026,
	       2664552812, 2095630716, 1099988794, 4142196794, 2544506753,
	       3485384650, 430826333, 3924498758, 983842871, 559469780,
	       3046537394, 2558191397, 1748641471, 1703543157, 2592035313,
	       2251132756, 2856434124, 2430276451, 872764094, 317121707,
	       5966309, 614613705, 2441932614, 4081181581, 1363577429,
	       3826195148, 2914574007, 2140015550, 2722653761, 530702262,
	       3776839949, 3174244398, 2662996664, 1756025237, 3550819102,
	       3080894760, 281074394, 4231680860, 1586364407, 885384955,
	       1179007550, 931623610, 3518953087, 4271433909, 2889139566,
	       338082013, 1870466325, 4025577775, 1558936021, 2570741014,
	       90342133, 1083987943, 1785481425, 1921212667, 3164342992,
	       1489324569, 603530523, 952851722, 2380944844, 3335854133
	      ],
    Refarray =
	[
	 1062977953, 3988658264, 3431706209, 1392605999, 4228283283,
	 2176715587, 1174527495, 1437388515, 1427996751, 695075490,
	 1301589112, 2690299642, 2598744544, 4174173975, 3840835486,
	 649977762, 3847428333, 3934078688, 4132816682, 556148516,
	 2851104082, 3954729007, 3097254441, 860119530, 607379520,
	 3718940465, 2709081067, 813237911, 2924835801, 2963392311,
	 3680758495, 1577302373, 3824698389, 2815029755, 3735459688,
	 1049070169, 362381609, 2957904656, 372615294, 3089059009,
	 2922792390, 850518085, 1949211416, 2774780728, 958090172,
	 1402882513, 884435661, 2707170196, 4040686310, 3303235824,
	 531013120, 1120643530, 3743098775, 2782106294, 1873189429,
	 3925566315, 3963388587, 1020947340, 3331747991, 965762908,
	 1951956255, 3746908851, 3237005575, 3521733560, 2020343472,
	 3519323690, 3283214119, 732274313, 3583292148, 1482011760,
	 571098358, 1348921825, 3758785517, 3183635786, 4174957504,
	 87235097, 2463718310, 3219991336, 4058881618, 3157574682,
	 2461829889, 3221549242, 1503840346, 3271995478, 1186014072,
	 2999824180, 3608855116, 3164700504, 490219523, 61835442,
	 2852281519, 2016590083, 985075993, 4116522450, 2631194335,
	 3859050228, 3316723388, 380634589, 1221404336, 1067167387,
	 689027224, 4266641514, 1121616698, 3536706232, 1119158170,
	 2180719025, 2498648561, 2504146192, 2311035163, 845621371,
	 4128509118, 3892985425, 1813068737, 2460350520, 3759123765,
	 3296755451, 1816280435, 1337283858, 1475630799, 3256862205,
	 1337643899, 3513481577, 1988910274, 16415099, 2657012513,
	 1443983529, 418728586, 3845107811, 3061513829, 4155867140,
	 1134954493, 1447378215, 2302142465, 255878528, 3127668772,
	 510234782, 3776394042, 4141964975, 1650621698, 1533858893,
	 1209322108, 4029779072, 162792549, 3181781509, 1100835531,
	 2363857919, 3538513172, 3684647403, 1384987708, 4019976256,
	 3731558642, 2229919300, 2328038081, 114481344, 1204695341,
	 3806584361, 3052259902, 758156143, 1922833515, 2512455614,
	 1959267688, 3979468422, 939313070, 867267185, 1125655886,
	 2449907737, 2089431866, 2051025568, 3380263529, 3233391830,
	 975418890, 312209732, 868932083, 2293558246, 3815276622,
	 2990754247, 3499722318, 932565535, 444827781, 1528462469,
	 2698714898, 2743756627, 3434008644, 873788496, 3380936986,
	 3608899544, 953021925, 3451735586, 2250710574, 3468720220,
	 3343718905, 4035831874, 3954118972, 2248859214, 3984572623,
	 753461748, 1644933373, 2531152575, 2122960842, 2811679914,
	 1404866161, 4046601927, 2052546518, 3297455234, 404120354,
	 720034026, 2140471195, 4273885119, 535493623, 639530637,
	 1539978282, 3429289165, 518639888, 2686788213, 3775498952,
	 1164531239, 2986965634, 3361563406, 2584579727, 2785235835,
	 733820092, 2268011329, 38148886, 737053025, 1628043757,
	 2544174810, 1648477722, 3709221873, 1379149111, 3531979758,
	 1221572282, 1563825729, 4253854479, 65433694, 533775106,
	 3222053881, 1729749449, 255087793, 3913625882, 553608014,
	 3024452738, 853024724, 2463017395, 3795560372, 1312860406,
	 2993638562, 938799276, 2581767293, 666831235, 1325927429,
	 1365838766, 61120276, 353502425, 2544639597, 1678046875,
	 764979350, 3168164174, 4077951098, 2277469483, 1912714498,
	 942908935, 1515872309, 2846964651, 2597034560, 3590871645,
	 1807427631, 1567315708, 3057991288, 773104571, 1735252788,
	 4186000299, 2439697319, 3799133606, 1489084279, 3255647577,
	 209954954, 2997581608, 2649120094, 3480122550, 2452457542,
	 3651928132, 3834048357, 4209272756, 3224959801, 2216933822,
	 893314057, 2294323056, 3749294512, 3080920488, 561037491,
	 3338761342, 447355527, 2338440308, 1737592883, 422327385,
	 4258522190, 1209183807, 2690327397, 167638878, 3330526580,
	 2319258588, 4220970122, 3447686174, 3965143099, 3942838788,
	 1862484277, 749652831, 173916209, 1387371801, 831597358,
	 99626001, 4080184935, 2910604269, 1319899287, 1767393944,
	 2788122967, 3943547548, 825406912, 2891560664, 895801096,
	 4072883032, 152388381, 3474538897, 9335402, 1428918622,
	 3871291263, 2615658331, 1528089976, 1289521459, 1788424614,
	 2375251067, 313787483, 2230744792, 165487802, 3369546802,
	 1975904289, 614861503, 4077435827, 894834880, 3431452511,
	 507597583, 1236954312, 1177004543, 3043832377, 2007301139,
	 891305779, 1369806077, 2295518537, 4280670275, 2293751897,
	 2665524490, 2040163654, 222042893, 1844523211, 241378809,
	 1879443735, 2127424351, 2924350603, 1574825940, 1415259711,
	 387967870, 61935243, 3388729280, 2841013010, 1520433792,
	 1784720886, 3291949677, 3688434613, 1394655683, 4211258084,
	 2073085422, 1989061149, 2512433879, 2022998905, 1191788973,
	 2122532652, 943439225, 869264260, 1539795484, 2865559700,
	 2713151187, 3364233838, 1313990094, 4080274575, 1894558395,
	 2109055874, 4035039714, 1863026199, 3278302265, 3444105052,
	 4043443818, 3568442974, 725986502, 4126681387, 3384084611,
	 2525863321, 2603581177, 4170330001, 3461395479, 2284849407,
	 467709468, 2858763673, 3994399223, 2096515112, 1252359120,
	 1161325666, 2552110153, 2015904716, 3028085166, 2823289225,
	 599932643, 3002926624, 3776820139, 2852420574, 2198968094,
	 3704374112, 3352458013, 1026597381, 1333645364, 3464629087,
	 1219584571, 905644983, 730345625, 319080809, 850459661,
	 3751927743, 2417085524, 642165059, 2635546304, 2495822510,
	 2581598917, 3141929484, 163520054, 93529769, 2604848738,
	 3827256775, 4210137441, 3279988863, 3635764092, 1731797228,
	 3619866751, 2303119102, 4071670885, 1497688282, 458621690,
	 872290947, 1608713899, 1292788211, 16976616, 781503920,
	 2177679833, 2546012879, 3409301963, 1934614646, 465669708,
	 2110834381, 2620642698, 3280100156, 4261091393, 3809656207,
	 1350791638, 2815489944, 901265186, 2524542494, 2963003163,
	 3390714350, 3819328865, 3332582778, 2605968629, 3924460738,
	 1461359983, 1742885903, 2740806815, 3604177662, 1332560478,
	 193881028, 3574724144, 2995765505, 1266600026, 3843889955,
	 1337559312, 1519245169, 3050842016, 3917841145, 1260596819,
	 311383843, 664281834, 3441373905, 2773077312, 1321238534,
	 3120829650, 1540397577, 1141700233, 193940413, 471171264,
	 2943124290, 1744564942, 3658007369, 932570102, 3392154961,
	 1423050826, 4267569834, 2388121391, 3601196137, 3210156547,
	 609050404, 3357791300, 3199268170, 1581068879, 817572355,
	 1667488394, 2835369758, 66797414, 408411894, 2121962482,
	 2549139641, 3823996660, 732552958, 1056231775, 1294860719,
	 2216132903, 3574131052, 3723086356, 2115092646, 1210146588,
	 1308307031, 4253640262, 1833388949, 4086070180, 4248546214,
	 3194688214, 2735925048, 1480102152, 2533650791, 650012195,
	 3394827872, 1276090814, 243151392, 2709788773, 3973232265,
	 304359816, 2104405020, 1625960938, 942064417, 1903389659,
	 1242894605, 1986766019, 2093860487, 1561808784, 1416089757,
	 4290630606, 2031355425, 3787610922, 3341659357, 2306129900,
	 796897271, 3613711854, 3454622255, 2096307286, 3899856244,
	 2168793787, 811488054, 3003959093, 920536190, 235236856,
	 870345839, 2125533070, 3150976410, 1602865420, 1686727350,
	 1608193802, 2741573520, 4124857144, 1714662903, 2275463448,
	 652180875, 2431468754, 452841239, 3278749002, 3303889829,
	 4152546007, 616695080, 3812554858, 4164332608, 967496881,
	 2727662435, 1846779112, 2458739734, 2618013467, 1628521962,
	 1419194199, 3966902011, 3179263968, 4148167983, 3842398422,
	 509032837, 1175303318, 1934363098, 4224144523, 1995784127,
	 1302446734, 2589103897, 2297122363, 2683613448, 973146994,
	 4187092500, 294073826, 2493057870, 1349784078, 1603343250,
	 1950753701, 836900536, 4032766444, 3858987808, 1092338324,
	 2481664746, 2056962973, 3232626732, 4231314042, 1113897298,
	 1886299844, 2322607178, 4064885313, 1203830751, 2912214584,
	 834402639, 1208292382, 1999114528, 3758660474, 1373518547,
	 2548109435, 3519395113, 1679598283, 1638789519, 2238935587,
	 2844652636, 2041665859, 3234305169, 3533221867, 924228217,
	 4067605767, 61845809, 1238213296, 2838594765, 589764255,
	 1936987607, 1391268719, 3827406164, 2712481406, 2729640782,
	 4288074168, 857810267, 1054017611, 3634461966, 2234205278,
	 928947596, 1488919655, 3043038432, 714434122, 3069879143,
	 2689232763, 2816694376, 2617247742, 477570758, 1746369489,
	 172225618, 3443843044, 3721316126, 3036844258, 700862569,
	 2685768491, 3798794306, 531509971, 2468704980, 163723231,
	 1001440253, 1923631932, 353653849, 3043181127, 565463912,
	 1688707242, 3301654360, 3291779647, 110569235, 435896924,
	 2158166724, 164829096, 478630567, 1583156167, 4161886811,
	 2490103241, 2049527522, 3398164752, 702587304, 1961268132,
	 1974777464, 2406604166, 3184969912, 1731222480, 2395181225,
	 2072651612, 4242978947, 180388302, 1618159866, 461166179,
	 3035596072, 837688430, 1161716079, 3450078309, 3387286520,
	 453546686, 3999327789, 329294889, 3068190473, 3936666478,
	 1256948525, 3461282703, 2849746490, 3334649727, 4240625231,
	 585392901, 3135247071, 664765953, 4215090368, 2635308248,
	 593999569, 3963326537, 1409143395, 3509200733, 3667922064,
	 668012972, 1872586565, 4020510717, 3211932514, 1160080851,
	 4134725660, 2181587848, 1382851160, 4226977682, 3945723623,
	 1633583368, 2675890776, 1942255133, 1667454516, 1812284667,
	 4185572712, 3022303989, 2954682536, 3102137388, 2951656276,
	 1098054436, 1916247543, 1254534493, 2901272726, 3530113571,
	 4179948015, 2677554703, 1449372317, 1848303323, 2571715881,
	 1323382615, 7182921, 1335537230, 230388913, 23501567,
	 4049151880, 3148947783, 1592021722, 2658376882, 4213562912,
	 1395346159, 152368572, 2348516725, 2748023749, 1042229554,
	 2056811387, 4128932243, 2116447834, 2871666904, 2932907257,
	 3634967378, 3507472489, 1234512567, 181112439, 1649268488,
	 1309531357, 991020632, 4095945632, 4106363582, 44612861,
	 3169431716, 3527387294, 270209417, 1135425065, 357583385,
	 3320452294, 241402391, 2208094317, 2741285578, 658304376,
	 1985477119, 3613060938, 1671700863, 3315652183, 1147928999,
	 3507584064, 3659676075, 3958123430, 3789032232, 213778736,
	 113362053, 823154826, 679416244, 3093555549, 952331786,
	 483720823, 3923189529, 511116411, 2592246221, 1981105076,
	 1309731863, 1878031973, 831041222, 2709217523, 3103009700,
	 3265900884, 2813913857, 1561537471, 2659001234, 443425288,
	 3519777403, 2051589061, 2469814936, 1270770633, 1326141892,
	 1910762052, 3515605318, 3693223622, 326554153, 3077815192,
	 3142218763, 1913029727, 3109111769, 3260800278, 4004110215,
	 1087796599, 4132376308, 1577851316, 369005883, 3651129230,
	 3071137486, 989815298, 2762688254, 2118736280, 3692405840,
	 530238339, 639311061, 229507947, 4292303116, 2143249556,
	 3680229821, 580416601, 3298651230, 3875274605, 199468613,
	 842402642, 2811863886, 68938908, 1985484503, 669875367,
	 967535426, 1278692878, 3038302253, 3140415113, 558809104,
	 619436771, 2604294408, 1258951495, 3095806816, 2922083768,
	 4028913928, 2785297592, 1170640660, 4150329982, 2289198195,
	 1789527031, 2051300571, 1644716864, 1941173724, 1779210948,
	 146650713, 3898640830, 2896145212, 1130810947, 1632710659,
	 1261716023, 3646761445, 3499688921, 1806682856, 2510501108,
	 3139606161, 2520429840, 2481922341, 4116609971, 1543857241,
	 1720918944, 2658985854, 2804551144, 606553611, 2000318963,
	 3845609019, 1025171844, 758006856, 966724549, 180359768,
	 1712807788, 3323312958, 1481876703, 2108993945, 936187231,
	 1478404033, 1457786023, 1609921868, 2191632727, 2508111676,
	 4180102827, 1578831525, 2016382398, 1587556765, 1211681661,
	 4171013367, 4115760320, 3753323748, 218758715, 3065466885,
	 1470205391, 2463635171, 2567063470, 123639014, 3119232552,
	 2095587371, 3203819687, 2039462058, 1700395840, 2495844348,
	 3737134992, 1708331935, 2494394257, 246547750, 158878228,
	 2192533008, 816911028, 4247527774, 1463348146, 3902414713,
	 1212566211, 1601253113, 879983220, 4196777127, 2009850819,
	 283876563, 3045658651, 369742524, 1926673106, 1526954735,
	 3546901483, 4071394124, 519539678, 298210345, 4143734272,
	 581648927, 779209738, 4086935284, 1377998651, 2593828532,
	 87588891, 505935827, 405427193, 163470145, 2556596192,
	 32480673, 487726617, 383705146, 2900145016, 3379405498,
	 3865627777, 1502203695, 4075458576, 1031563820, 3316652859,
	 1139327012, 2247677950, 522475785, 1040797340, 975956695,
	 3208203744, 722884788, 2004479119, 171172741, 3261843831
	],
    {Refrand, Refarray}.

-endif. % TEST

%% end of module
