-- MegaI/0 by solidheron
-- MegaI/0 is script converted from MarI/O by SethBling
-- Feel free to use this code, but please do not redistribute it.
-- Intended for use with the BizHawk emulator and Megaman X US version 1.0
-- make sure you have a save state named "DP1.state" at the beginning of a level,
-- and put a copy in both the Lua folder and the root directory of BizHawk.
	Filename = "DP1.state"
	ButtonNames = {
		"A",
		"B",
		"X",
		"Y",
		"Up",
		"Down",
		"Left",
		"Right",
	}

BoxRadius = 6
InputSize = (BoxRadius*2+1)*(BoxRadius*2+1)

Inputs = InputSize+1
Outputs = #ButtonNames

Population = 300
DeltaDisjoint = 2.0
DeltaWeights = 0.4
DeltaThreshold = 1.0

StaleSpecies = 15

MutateConnectionsChance = 0.25
PerturbChance = 0.90
CrossoverChance = 0.75
LinkMutationChance = 2.0
NodeMutationChance = 0.50
BiasMutationChance = 0.40
StepSize = 0.1
DisableMutationChance = 0.4
EnableMutationChance = 0.2

TimeoutConstant = 20

MaxNodes = 1000000
function getPositions()
		MMan_X_pos_two_most_sig_bit = mainmemory.read_u8(0x0BAE); --megamans x position for how many rooms (aka 16 by 16 tiles) megaman is from the left edge of the stage
		MMan_X_pos_two_least_sig_bit = mainmemory.read_u8(0x0BAD); --megamans x position tile and pixel count
		MMan_Y_pos_two_most_sig_bit = mainmemory.read_u8(0x0BB1); --megamans Y position for how many rooms (aka 16 by 16 tiles) megaman is from the top edge of the stage
		MMan_Y_pos_two_least_sig_bit = mainmemory.read_u8(0x0BB0); --megamans y position tile and pixel count	
		MegaManX =  MMan_X_pos_two_most_sig_bit*0x100 + MMan_X_pos_two_least_sig_bit;
		MegaManY =  MMan_Y_pos_two_most_sig_bit*0x100 + MMan_Y_pos_two_least_sig_bit;
	
		local layer1x = memory.read_s16_le(0x00B4);
		local layer1y = memory.read_s16_le(0x00B6);
		
		screenX = MegaManX-layer1x
		screenY = MegaManY-layer1y
end
current_stage_number = mainmemory.read_u8(0x1f7A)
function getTile(dx,dy) -- distance from marioX in both x and y coordinates 
		--needs to update tile info on every stage
		x = MegaManX + dx
		y = MegaManY + dy		
		local tile_hex_values = memory.read_u32_le(hex_address_finder_iter_2(math.floor(x/0x100),math.floor((x%0x100)/0x10),math.floor(y/0x100),math.floor((y%0x100)/0x10)))%0x10000
		--memory.read_u32_le(tile_hex_address[i +y_offset][j+x_offset])%0x10000
		--in order to adapt funtion the tiles have x and y cordinates have to be pushed in other functions to get hex address that will be read in memory
		
		if(current_stage_number == 0) then
			passables_set = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,82,85,86,87,88,91,92,93,94,97,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,186,187,188,191,192,195,196,197,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,331,332,333,334,338,339,340,359,363,364,365,366,379,380,387,388,389,390,391,392,393,394,395,396,397,398,399,403,408,409,410,411,416,417,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731,732,733,734,735,736,737,738,739,740,741,742,746,747,748,753,760,763,767,768,769,770,771,772,773,774,775,776,777,778,779,780,782,784,787,789,791,800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815,816,817,818,819,820,821,822,823,824,826,827,828,829,830,831,832,833,834,835,836,837,838,839,840,841,842,843,844,845,846,847,848,849,850,851,852,853,854,855,856,857,858,859,860,861,862,863,864,867,868,869,870,871,872,873,874,875,876,877,878,879,880,881,882,883,884,885,886,887,888,889,890,891,892,893,894,895,896,897,898,899,900,901,902,903,904,905,906,918,926,936,948,949,950,951,952,953,954,955,956,973,974,975,976,977,978,979,980,981,982,983,984,985,986,987,988,989,990,991,992,993,998,999,1000,1004,1015,1016,1017,1018,1019,1020,1021,1022,1023,1027,1033,1034,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1073,1077,1085,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104,1105,1106,1107,1108,1109,1111,1112,1114,1115,1120,1121,1122,1123,1124,1127,1130,1131,1132,1148,1149,1150,1151,1152,1153,1154,1157,1158,1159,1160,1161,1162,1163,1164,1165,1166,1167,1168,1169,1170,1171,1172,1182,1183,1184,1185,1186,1187,1188,1189,1190,1191,1193,1198,1199,1200,1201,1202,1203,1204,1205,1206,1207,1210,1211,1212,1213,1214,1215,1216,1217,1218,1219,1222,1223,1224,1225,1226,1227,1228,1229,1230,1231,1232,1233,1234,1237,1238,1239,1243,1244,1245,1246,1247,1248,1249,1250,1251,1252,1253,1254,1255,1256,1257,1258,1259,1261,1262,1263,1264,1267,1268,1269,1270,1271,1272,1273,1274,1275,1276,1277,1278,1279,1280,1281,1282,1283,1284,1285,1286,1287,1288,1295,1296,1297,1300,1302,1303,1304,1305,1306,1307,1308,1309,1310,1311,1312,1313,1314,1315,1316,1317,1318,1319,1320,1321,1322,1323,1324,1325,1326,1327,1328,1329,1330,1331,1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1343,1344,1346,1347,1348,1349,1350,1351,1352,1353,1354,1355,1356,1357,1358,1359,1360,1361,1362,1363,1364,1365,1366,1367,1368,1369,1370,1371,1372,1373,1374,1375,1376,1377,1378,1379,1383,1384,1385,1386,1387,1388,1389,1390,1391,1392,1393,1394,1395,1396,1397,1398,1399,1400,1401,1402,1403,1404,1405,1406,1407,1408,1409,1410,1411,1412,1413,1414,1415,1416,1417,1418,1419,1426,1437,1438,1439,1453,1463,1464,1465,1466,1467,1468,1469,1470,1471,1472,1475,1484,1493,1494,1495,1496,1497,1498,1499,1500,1501,1502,1503,1512,1513,1514,1515,1516,1517,1518,1519,1520,1521,1522,1523,1524,1525,1526,1527,1528,1529,1530,1531,1532,1533,1534,1535,1536,1537,1538,1539,1540,1541,1542,1543,1544} 
			Hard_floor_set = {68,69,70,71,72,73,74,75,76,77,78,79,80,81,83,84,89,90,95,96,98,99,149,150,185,189,190,193,194,198,328,329,330,335,336,337,344,347,348,349,350,351,352,353,354,355,356,357,358,360,361,362,367,368,369,370,371,372,373,374,375,376,377,378,381,382,383,384,385,386,404,405,412,413,414,415,418,419,420,421,422,423,561,562,743,744,745,750,751,752,754,756,757,758,759,761,762,764,765,766,781,783,785,786,788,790,792,793,794,795,796,797,798,799,825,865,866,910,911,912,913,914,915,916,917,919,920,921,922,923,924,925,928,929,930,931,932,933,934,935,937,938,939,940,941,942,943,944,945,946,947,957,958,959,960,961,962,963,964,965,966,967,968,969,994,995,996,997,1001,1002,1003,1005,1006,1007,1008,1009,1010,1011,1012,1013,1014,1064,1065,1066,1067,1068,1069,1070,1071,1072,1074,1075,1076,1078,1079,1080,1081,1082,1083,1084,1116,1117,1118,1119,1125,1126,1128,1129,1133,1134,1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147,1155,1156,1173,1174,1175,1176,1177,1178,1179,1180,1181,1194,1195,1196,1197,1209,1220,1221,1235,1236,1240,1241,1242,1260,1265,1266,1298,1299,1345,1420,1421,1422,1423,1424,1425,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,1440,1441,1442,1443,1444,1445,1446,1447,1448,1449,1450,1451,1452,1454,1455,1456,1457,1458,1459,1460,1461,1462,1473,1474,1476,1477,1478,1479,1480,1481,1482,1483,1485,1486,1487,1488,1489,1490,1491,1492,1504,1505,1506,1507,1508,1509,1510,1511}
			incline_tile_set = {341,342,343,345,346,400,401,402,406,407,749,755,907,908,909,927,970,971,972,1024,1025,1026,1028,1029,1030,1031,1032,1035,1110,1113,1192,1208,1289,1290,1291,1292,1293,1294,1301,1380,1381,1382,1545,1546,1547}
		elseif(current_stage_number == 2) then
			passables_set = {0,14,21,26,33,42,46,47,48,49,50,51,52,53,55,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,88,89,90,91,93,94,95,96,98,99,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,174,175,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,231,232,233,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,253,254,255,256,257,258,259,260,261,262,263,264,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,298,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,366,367,368,372,373,374,375,376,377,378,379,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,400,401,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,500,501,502,503,504,505,506,509,510,511,512,513,514,515,529,542,543,550,553,555,556,564,566,567,568,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,612,613,614,615,616,617,618,624,625,626,627,630,636,637,646,647,648,649,650,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,673,674,675,676,677,678,679,680,681,684,688,689,691,692,693,694,695,696,699,700,701,702,704,706,707,709,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731,732,733,734,735,736,737,738,743,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,774,775,776,777,778,779,780,781,782,783,784,785,796,797,798,799,800,801,802,803,804,805,806,807,808,809,810,812,818,819,820,821,822,823,824,825,829,830,831,832,835,836,837,838,842,843,844,845,846,847,848,849,855,856,857,858,859,860,861,862,863,864,865,866,867,868,869,870,871,872,873,874,875,876,877,878,879,880,881,882,883,884,885,886,887,888,889,890,891,892,893,894,895,896,897,898,899,900,901,902,903,904,905,906,907,908,909,910,911,912,913,914,915,916,917,918,919,920,921,922,923,924,925,926,954,957,958,961,964,965,966,967,970,971,972,973,974,978,986,987,991,993,1007,1008,1009,1023,1024,1025,1026,1027,1029,1030,1043,1049,1050,1051,1052,1054,1055,1056,1057,1058,1059,1061,1070,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1122,1123,1124,1128,1131,1132,1133,1135,1136,1138,1139,1140,1141,1142,1143,1153,1154,1155,1156,1157,1158,1168,1169,1170,1172,1173,1176,1184} 
			Hard_floor_set = {1,2,3,4,5,6,7,8,9,10,24,27,30,31,39,40,43,44,45,54,56,57,58,59,60,92,164,165,166,167,168,169,170,171,172,173,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,224,225,226,227,228,229,252,265,266,267,268,269,296,297,299,365,369,370,397,402,403,404,405,406,407,408,409,410,411,412,413,416,507,508,516,517,518,519,520,521,522,523,524,525,526,528,535,536,537,538,544,545,546,547,551,552,554,557,558,559,560,561,562,563,565,569,611,619,620,621,622,623,628,629,631,632,633,634,635,638,639,640,641,642,643,644,645,651,652,653,654,682,683,685,686,687,697,698,703,705,708,710,739,740,741,742,762,763,764,765,766,767,768,769,770,771,772,773,790,791,792,793,794,795,811,813,814,815,816,817,833,834,839,840,841,850,851,852,853,854,927,928,929,930,931,932,933,934,935,936,937,938,939,940,941,942,943,944,945,946,947,948,949,950,951,952,953,955,956,959,960,962,963,968,969,979,980,983,984,992,994,995,996,997,998,999,1000,1001,1002,1003,1004,1005,1006,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1044,1045,1046,1047,1048,1062,1063,1064,1065,1066,1067,1068,1069,1071,1072,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1086,1087,1088,1100,1101,1102,1103,1104,1105,1106,1107,1108,1121,1125,1126,1127,1129,1130,1134,1137,1144,1145,1146,1147,1148,1149,1150,1151,1152,1159,1160,1161,1162,1163,1164,1165,1166,1167,1171,1174,1175,1177,1178,1179,1180,1181,1182,1183,1186,1187,1188,1189,1190,1192,1194,1195,1196,1197}
			incline_tile_set = {11,12,13,15,16,17,18,19,20,22,23,25,28,29,32,34,35,36,37,38,41,87,97,100,121,122,230,234,235,371,398,399,414,415,460,527,530,531,532,533,534,539,540,541,548,549,690,786,787,788,789,975,976,977,981,982,985,988,989,990,1028,1053,1060,1185,1191,1193,1198,1199,1200,1201,1202,1203,1204,1205,1206,1207}
			hurt_tile = {826,827,828}
		elseif(current_stage_number == 8) then			
			passables_set = {0,10,11,12,13,19,20,21,22,23,24,25,29,32,33,34,35,39,40,41,42,44,46,47,48,49,56,57,58,59,62,63,64,74,75,77,80,81,82,86,87,94,95,99,103,104,111,112,113,114,115,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,152,153,154,155,157,158,159,160,162,163,164,165,166,167,168,170,171,172,173,174,175,176,178,179,180,181,182,183,184,185,186,188,189,190,191,192,193,194,195,196,197,201,202,203,204,208,209,210,211,212,213,215,216,217,218,244,245,246,247,248,249,250,271,277,283,284,285,290,291,292,294,295,296,297,298,300,301,302,305,306,307,308,309,312,313,314,315,316,317,318,319,320,321,322,323,327,328,329,334,335,336,337,338,339,340,341,342,343,347,348,352,355,358,359,360,361,362,363,364,369,373,374,375,376,389,390,391,392,393,394,395,400,420,421,422,423,429,430,431,432,436,438,439,440,441,442,443,451,452,453,454,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,481,482,483,484,485,486,489,492,493,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,530,531,532,533,534,535,536,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,676,677,678,679,687,688,689,690,691,692,693,694,695,703,704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,728,729,730,731,732,733,734,735,736,737,738,739,745,746,781,782,783,784,785,786,787,788,789,790,796,798,799,800,813,814,815,816,817,818,819,820,821,824,827,830,831,833,835,839,842,843,844,845,846,847,848,849,850,857,858,859,860,861,862,863,864,865,866,867,878,879,886,887,892,893,898,899,901,902,903,904,908,909,930,969,994,995,996,997,998,999,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1025,1027,1028,1029,1030,1031,1035,1036,1037,1038,1039,1040,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071,1072,1073,1074,1075,1077,1078,1079,1080,1081,1082,1085,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104,1105,1106,1107,1108,1109,1110,1111,1112,1116,1117,1118,1119,1121,1122,1123,1124,1125,1126,1127,1128,1129,1130,1131,1132,1133,1134,1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147,1148,1149,1154,1155,1156,1157,1158,1165,1166,1167,1168,1188,1189,1192,1193,1194,1195,1253,1254,1255,1258,1262,1269,1270,1271,1272,1299,1300,1301,1302,1303,1304,1305,1313,1318,1319,1320,1321,1328,1343,1353,1354,1356,1357,1358,1359,1360,1361,1362,1363,1364,1365,1366,1367,1368,1369,1370,1371,1372,1373,1374,1375,1376,1377,1378,1379,1380,1381,1382,1383,1384,1385,1386,1387,1388,1389,1390,1391,1392,1393,1394,1395,1396,1397,1398}  
			Hard_floor_set = {1,2,3,4,5,6,7,8,9,50,51,52,53,65,66,67,68,69,70,71,72,73,93,102,105,106,107,108,116,156,161,169,177,187,198,199,200,205,206,207,214,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,272,273,274,275,276,278,279,280,281,288,289,293,310,311,332,333,346,349,350,351,354,356,357,365,366,367,368,370,371,372,380,381,384,385,386,387,388,397,398,403,404,407,408,409,410,411,412,413,414,415,416,417,418,419,427,434,435,437,444,445,446,447,448,449,450,478,479,480,487,488,490,491,494,672,673,674,675,680,681,682,683,684,685,686,696,697,698,699,700,701,702,740,741,742,743,744,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,768,769,770,771,772,773,774,775,776,777,778,779,780,791,792,793,794,795,797,801,802,803,804,805,806,807,808,809,810,811,812,822,825,828,837,838,840,841,851,852,853,868,869,870,871,872,873,874,875,876,877,880,881,882,883,884,885,888,889,890,891,894,895,896,897,900,905,906,907,910,911,912,913,914,915,916,917,918,919,920,921,922,923,924,925,926,927,928,929,937,938,940,941,942,943,944,945,946,947,948,949,950,951,952,953,954,955,956,957,958,959,960,961,962,963,964,965,966,967,968,970,971,972,973,974,975,976,977,978,979,980,981,982,983,984,985,986,987,988,989,990,991,992,993,1010,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,1024,1026,1032,1033,1034,1041,1076,1083,1084,1113,1114,1115,1120,1150,1151,1152,1153,1159,1160,1161,1162,1163,1164,1169,1170,1171,1172,1173,1174,1175,1176,1177,1178,1179,1180,1181,1182,1183,1184,1185,1186,1187,1190,1191,1196,1197,1198,1199,1200,1201,1202,1203,1204,1205,1206,1207,1208,1209,1210,1211,1212,1213,1214,1215,1216,1217,1218,1219,1220,1221,1222,1223,1224,1225,1226,1227,1228,1229,1230,1231,1232,1233,1234,1235,1236,1237,1238,1239,1240,1241,1242,1243,1244,1245,1246,1247,1248,1249,1250,1251,1252,1256,1257,1259,1260,1261,1263,1264,1265,1266,1267,1268,1273,1274,1275,1276,1277,1278,1279,1280,1281,1282,1283,1284,1285,1286,1287,1288,1289,1290,1291,1292,1293,1294,1295,1296,1297,1298,1306,1307,1308,1309,1310,1311,1312,1314,1315,1316,1317,1322,1323,1324,1325,1326,1327,1329,1330,1331,1332,1333,1334,1335,1336,1337,1338,1339,1340,1341,1342,1344,1345,1346,1347,1348,1349,1350,1351,1352,1355}
			incline_tile_set = {14,15,16,17,18,26,27,28,30,31,36,37,38,43,45,54,55,60,61,76,78,79,83,84,85,88,89,90,91,92,96,97,98,100,101,109,110,151,282,286,287,299,303,304,324,325,326,330,331,344,345,353,377,378,379,382,383,396,399,401,402,405,406,424,425,426,428,433,513,529,640,641,642}
			hurt_tile = {823,826,829,832,834,836}
			instakill_tile = {854,855,856,931,932,933,934,935,936,939}
		end
		--print(current_stage_number)
		for i =1,#Hard_floor_set do
			if(tile_hex_values == Hard_floor_set[i]) then
				--print(Hard_floor_set[i])
				local one = 1
				return one;
			end
		end
		for i =1,#passables_set do
			if(tile_hex_values==passables_set[i]) then
				return 0;
			end
		end
		return -1 -- this is an error state hex values should be cataloged
end
function hex_address_finder_iter_2(X_most_sig_bit,X_second_least_sig_bit,Y_most_sig_bit,Y_second_least_sig_bit) --oficiall hexidecial address return
	--this will need more 
	local offset_input = 0x2000
	if(current_stage_number == 0) --this if state hiearchy is meant to database the offsets all megaman stages and levels have
		then
		if(Y_most_sig_bit==1) then
			offset_input = 0x2200;
	elseif(Y_most_sig_bit==2)
		then
			offset_input = 0x4C00;
		end
	elseif(current_stage_number == 8) then -- chill penguin stage
		if(Y_most_sig_bit==0x4) then
			offset_input = 0x6E00
		end
	elseif(current_stage_number == 3) then -- armor armadillo stage
		if(Y_most_sig_bit==0x1) then
			offset_input = 0x2400
		end
	elseif(current_stage_number == 6) then -- spark mandrill stage
		if(Y_most_sig_bit==0x3) then
			offset_input = 0x3A00
		end
	elseif(current_stage_number == 7) then -- Kuwanger stage
		if(Y_most_sig_bit==0x17) then
			offset_input = 0x7200
		end
	elseif(current_stage_number == 4) then -- Mammoth stage
		if(Y_most_sig_bit==0x2) then
			offset_input = 0x3800
		end
	elseif(current_stage_number == 2) then -- Chameleon stage
		if(Y_most_sig_bit==0x2) then
			offset_input = 0x5600
		end
	end
	hex_address_return = 0x200*X_most_sig_bit + 0x2*X_second_least_sig_bit + 0x20*Y_second_least_sig_bit + offset_input;
	return hex_address_return
end
function getSprites()
	local sprites = {}
	local offset_enemies_values = 0x0E68
	local enemy_data = 0;
	local enemy_ID = 0;
	for i =0,15 do
		enemy_data = mainmemory.read_u16_le(offset_enemies_values + 0xE+ 64*i)
		enemy_ID = mainmemory.read_u16_le(offset_enemies_values + 0xA+ 64*i)
		if(mainmemory.read_u16_le(offset_enemies_values + 0xE+ 64*i) ~= 0) then
			spritex = mainmemory.read_u16_le(offset_enemies_values + 0x6+ 64*i)*0x100 + math.floor(mainmemory.read_u16_le(offset_enemies_values + 0x4+ 64*i)/0x100)
			--enemy_x_pos_values.animation[i+1] = mainmemory.read_u16_le(offset_enemies_values + 0xE+ 64*i);
			spritey = mainmemory.read_u16_le(offset_enemies_values + 0x8+ 64*i);
			--a = getTile(offset_enemies_values + 0x5)
			b = mainmemory.read_u16_le(0xE68 + 0x6)
			sprites[#sprites+1] = {["x"]=spritex, ["y"]=spritey}
			--print(enemy_ID)
			if(enemy_ID == 41) then --this is used to add data for enemy data that occupy more than one tile
				sprites[#sprites+1] = {["x"]=spritex, ["y"]=spritey+16}
				sprites[#sprites+1] = {["x"]=spritex, ["y"]=spritey+32}
			end
		end
	end
	return sprites
end

function getExtendedSprites()
	local extended = {}
	local offset_enemies_values = 0x1428
	for i =0,15 do
		if(mainmemory.read_u16_le(offset_enemies_values + 0xE+ 64*i) ~= 0) then
			spritex = mainmemory.read_u16_le(offset_enemies_values + 0x6+ 64*i)*0x100 + math.floor(mainmemory.read_u16_le(offset_enemies_values + 0x4+ 64*i)/0x100)
			--enemy_x_pos_values.animation[i+1] = mainmemory.read_u16_le(offset_enemies_values + 0xE+ 64*i);
			spritey = mainmemory.read_u16_le(offset_enemies_values + 0x8+ 64*i);
			--a = getTile(offset_enemies_values + 0x5)
			b = mainmemory.read_u16_le(0xE68 + 0x6)
			extended[#extended+1] = {["x"]=spritex, ["y"]=spritey}
		end
	end
	return extended
end

function getInputs()
	getPositions()
	
	sprites = getSprites()
	extended = getExtendedSprites()
	
	local inputs = {}
	
	for dy=-BoxRadius*16,BoxRadius*16,16 do
		for dx=-BoxRadius*16,BoxRadius*16,16 do
			inputs[#inputs+1] = 0
			
			tile = getTile(dx, dy)
			if tile == 1 then --and MegaManY+dy < 0x1F0 then
				--print('hit')
				inputs[#inputs] = 1
			end
			
			for i = 1,#sprites do
				distx = math.abs(sprites[i]["x"] - (MegaManX+dx))
				disty = math.abs(sprites[i]["y"] - (MegaManY+dy))
				if distx <= 8 and disty <= 8 then
					inputs[#inputs] = -1
				end
			end

			for i = 1,#extended do
				distx = math.abs(extended[i]["x"] - (MegaManX+dx))
				disty = math.abs(extended[i]["y"] - (MegaManY+dy))
				if distx < 8 and disty < 8 then
					inputs[#inputs] = -1
				end
			end
		end
	end
	
	--mariovx = memory.read_s8(0x7B)
	--mariovy = memory.read_s8(0x7D)
	
	return inputs
end

function sigmoid(x)
	return 2/(1+math.exp(-4.9*x))-1
end

function newInnovation()
	pool.innovation = pool.innovation + 1
	return pool.innovation
end

function newPool()
	local pool = {}
	pool.species = {}
	pool.generation = 0
	pool.innovation = Outputs
	pool.currentSpecies = 1
	pool.currentGenome = 1
	pool.currentFrame = 0
	pool.maxFitness = 0
	
	return pool
end

function newSpecies()
	local species = {}
	species.topFitness = 0
	species.staleness = 0
	species.genomes = {}
	species.averageFitness = 0
	
	return species
end

function newGenome()
	local genome = {}
	genome.genes = {}
	genome.fitness = 0
	genome.adjustedFitness = 0
	genome.network = {}
	genome.maxneuron = 0
	genome.globalRank = 0
	genome.mutationRates = {}
	genome.mutationRates["connections"] = MutateConnectionsChance
	genome.mutationRates["link"] = LinkMutationChance
	genome.mutationRates["bias"] = BiasMutationChance
	genome.mutationRates["node"] = NodeMutationChance
	genome.mutationRates["enable"] = EnableMutationChance
	genome.mutationRates["disable"] = DisableMutationChance
	genome.mutationRates["step"] = StepSize
	
	return genome
end

function copyGenome(genome)
	local genome2 = newGenome()
	for g=1,#genome.genes do
		table.insert(genome2.genes, copyGene(genome.genes[g]))
	end
	genome2.maxneuron = genome.maxneuron
	genome2.mutationRates["connections"] = genome.mutationRates["connections"]
	genome2.mutationRates["link"] = genome.mutationRates["link"]
	genome2.mutationRates["bias"] = genome.mutationRates["bias"]
	genome2.mutationRates["node"] = genome.mutationRates["node"]
	genome2.mutationRates["enable"] = genome.mutationRates["enable"]
	genome2.mutationRates["disable"] = genome.mutationRates["disable"]
	
	return genome2
end

function basicGenome()
	local genome = newGenome()
	local innovation = 1

	genome.maxneuron = Inputs
	mutate(genome)
	
	return genome
end

function newGene()
	local gene = {}
	gene.into = 0
	gene.out = 0
	gene.weight = 0.0
	gene.enabled = true
	gene.innovation = 0
	
	return gene
end

function copyGene(gene)
	local gene2 = newGene()
	gene2.into = gene.into
	gene2.out = gene.out
	gene2.weight = gene.weight
	gene2.enabled = gene.enabled
	gene2.innovation = gene.innovation
	
	return gene2
end

function newNeuron()
	local neuron = {}
	neuron.incoming = {}
	neuron.value = 0.0
	
	return neuron
end

function generateNetwork(genome)
	local network = {}
	network.neurons = {}
	
	for i=1,Inputs do
		network.neurons[i] = newNeuron()
	end
	
	for o=1,Outputs do
		network.neurons[MaxNodes+o] = newNeuron()
	end
	
	table.sort(genome.genes, function (a,b)
		return (a.out < b.out)
	end)
	for i=1,#genome.genes do
		local gene = genome.genes[i]
		if gene.enabled then
			if network.neurons[gene.out] == nil then
				network.neurons[gene.out] = newNeuron()
			end
			local neuron = network.neurons[gene.out]
			table.insert(neuron.incoming, gene)
			if network.neurons[gene.into] == nil then
				network.neurons[gene.into] = newNeuron()
			end
		end
	end
	
	genome.network = network
end

function evaluateNetwork(network, inputs)
	table.insert(inputs, 1)
	if #inputs ~= Inputs then
		console.writeline("Incorrect number of neural network inputs.")
		return {}
	end
	
	for i=1,Inputs do
		network.neurons[i].value = inputs[i]
	end
	
	for _,neuron in pairs(network.neurons) do
		local sum = 0
		for j = 1,#neuron.incoming do
			local incoming = neuron.incoming[j]
			local other = network.neurons[incoming.into]
			sum = sum + incoming.weight * other.value
		end
		
		if #neuron.incoming > 0 then
			neuron.value = sigmoid(sum)
		end
	end
	
	local outputs = {}
	for o=1,Outputs do
		local button = "P1 " .. ButtonNames[o]
		if network.neurons[MaxNodes+o].value > 0 then
			outputs[button] = true
		else
			outputs[button] = false
		end
	end
	
	return outputs
end

function crossover(g1, g2)
	-- Make sure g1 is the higher fitness genome
	if g2.fitness > g1.fitness then
		tempg = g1
		g1 = g2
		g2 = tempg
	end

	local child = newGenome()
	
	local innovations2 = {}
	for i=1,#g2.genes do
		local gene = g2.genes[i]
		innovations2[gene.innovation] = gene
	end
	
	for i=1,#g1.genes do
		local gene1 = g1.genes[i]
		local gene2 = innovations2[gene1.innovation]
		if gene2 ~= nil and math.random(2) == 1 and gene2.enabled then
			table.insert(child.genes, copyGene(gene2))
		else
			table.insert(child.genes, copyGene(gene1))
		end
	end
	
	child.maxneuron = math.max(g1.maxneuron,g2.maxneuron)
	
	for mutation,rate in pairs(g1.mutationRates) do
		child.mutationRates[mutation] = rate
	end
	
	return child
end

function randomNeuron(genes, nonInput)
	local neurons = {}
	if not nonInput then
		for i=1,Inputs do
			neurons[i] = true
		end
	end
	for o=1,Outputs do
		neurons[MaxNodes+o] = true
	end
	for i=1,#genes do
		if (not nonInput) or genes[i].into > Inputs then
			neurons[genes[i].into] = true
		end
		if (not nonInput) or genes[i].out > Inputs then
			neurons[genes[i].out] = true
		end
	end

	local count = 0
	for _,_ in pairs(neurons) do
		count = count + 1
	end
	local n = math.random(1, count)
	
	for k,v in pairs(neurons) do
		n = n-1
		if n == 0 then
			return k
		end
	end
	
	return 0
end

function containsLink(genes, link)
	for i=1,#genes do
		local gene = genes[i]
		if gene.into == link.into and gene.out == link.out then
			return true
		end
	end
end

function pointMutate(genome)
	local step = genome.mutationRates["step"]
	
	for i=1,#genome.genes do
		local gene = genome.genes[i]
		if math.random() < PerturbChance then
			gene.weight = gene.weight + math.random() * step*2 - step
		else
			gene.weight = math.random()*4-2
		end
	end
end

function linkMutate(genome, forceBias)
	local neuron1 = randomNeuron(genome.genes, false)
	local neuron2 = randomNeuron(genome.genes, true)
	 
	local newLink = newGene()
	if neuron1 <= Inputs and neuron2 <= Inputs then
		--Both input nodes
		return
	end
	if neuron2 <= Inputs then
		-- Swap output and input
		local temp = neuron1
		neuron1 = neuron2
		neuron2 = temp
	end

	newLink.into = neuron1
	newLink.out = neuron2
	if forceBias then
		newLink.into = Inputs
	end
	
	if containsLink(genome.genes, newLink) then
		return
	end
	newLink.innovation = newInnovation()
	newLink.weight = math.random()*4-2
	
	table.insert(genome.genes, newLink)
end

function nodeMutate(genome)
	if #genome.genes == 0 then
		return
	end

	genome.maxneuron = genome.maxneuron + 1

	local gene = genome.genes[math.random(1,#genome.genes)]
	if not gene.enabled then
		return
	end
	gene.enabled = false
	
	local gene1 = copyGene(gene)
	gene1.out = genome.maxneuron
	gene1.weight = 1.0
	gene1.innovation = newInnovation()
	gene1.enabled = true
	table.insert(genome.genes, gene1)
	
	local gene2 = copyGene(gene)
	gene2.into = genome.maxneuron
	gene2.innovation = newInnovation()
	gene2.enabled = true
	table.insert(genome.genes, gene2)
end

function enableDisableMutate(genome, enable)
	local candidates = {}
	for _,gene in pairs(genome.genes) do
		if gene.enabled == not enable then
			table.insert(candidates, gene)
		end
	end
	
	if #candidates == 0 then
		return
	end
	
	local gene = candidates[math.random(1,#candidates)]
	gene.enabled = not gene.enabled
end

function mutate(genome)
	for mutation,rate in pairs(genome.mutationRates) do
		if math.random(1,2) == 1 then
			genome.mutationRates[mutation] = 0.95*rate
		else
			genome.mutationRates[mutation] = 1.05263*rate
		end
	end

	if math.random() < genome.mutationRates["connections"] then
		pointMutate(genome)
	end
	
	local p = genome.mutationRates["link"]
	while p > 0 do
		if math.random() < p then
			linkMutate(genome, false)
		end
		p = p - 1
	end

	p = genome.mutationRates["bias"]
	while p > 0 do
		if math.random() < p then
			linkMutate(genome, true)
		end
		p = p - 1
	end
	
	p = genome.mutationRates["node"]
	while p > 0 do
		if math.random() < p then
			nodeMutate(genome)
		end
		p = p - 1
	end
	
	p = genome.mutationRates["enable"]
	while p > 0 do
		if math.random() < p then
			enableDisableMutate(genome, true)
		end
		p = p - 1
	end

	p = genome.mutationRates["disable"]
	while p > 0 do
		if math.random() < p then
			enableDisableMutate(genome, false)
		end
		p = p - 1
	end
end

function disjoint(genes1, genes2)
	local i1 = {}
	for i = 1,#genes1 do
		local gene = genes1[i]
		i1[gene.innovation] = true
	end

	local i2 = {}
	for i = 1,#genes2 do
		local gene = genes2[i]
		i2[gene.innovation] = true
	end
	
	local disjointGenes = 0
	for i = 1,#genes1 do
		local gene = genes1[i]
		if not i2[gene.innovation] then
			disjointGenes = disjointGenes+1
		end
	end
	
	for i = 1,#genes2 do
		local gene = genes2[i]
		if not i1[gene.innovation] then
			disjointGenes = disjointGenes+1
		end
	end
	
	local n = math.max(#genes1, #genes2)
	
	return disjointGenes / n
end

function weights(genes1, genes2)
	local i2 = {}
	for i = 1,#genes2 do
		local gene = genes2[i]
		i2[gene.innovation] = gene
	end

	local sum = 0
	local coincident = 0
	for i = 1,#genes1 do
		local gene = genes1[i]
		if i2[gene.innovation] ~= nil then
			local gene2 = i2[gene.innovation]
			sum = sum + math.abs(gene.weight - gene2.weight)
			coincident = coincident + 1
		end
	end
	
	return sum / coincident
end
	
function sameSpecies(genome1, genome2)
	local dd = DeltaDisjoint*disjoint(genome1.genes, genome2.genes)
	local dw = DeltaWeights*weights(genome1.genes, genome2.genes) 
	return dd + dw < DeltaThreshold
end

function rankGlobally()
	local global = {}
	for s = 1,#pool.species do
		local species = pool.species[s]
		for g = 1,#species.genomes do
			table.insert(global, species.genomes[g])
		end
	end
	table.sort(global, function (a,b)
		return (a.fitness < b.fitness)
	end)
	
	for g=1,#global do
		global[g].globalRank = g
	end
end

function calculateAverageFitness(species)
	local total = 0
	
	for g=1,#species.genomes do
		local genome = species.genomes[g]
		total = total + genome.globalRank
	end
	
	species.averageFitness = total / #species.genomes
end

function totalAverageFitness()
	local total = 0
	for s = 1,#pool.species do
		local species = pool.species[s]
		total = total + species.averageFitness
	end

	return total
end

function cullSpecies(cutToOne)
	for s = 1,#pool.species do
		local species = pool.species[s]
		
		table.sort(species.genomes, function (a,b)
			return (a.fitness > b.fitness)
		end)
		
		local remaining = math.ceil(#species.genomes/2)
		if cutToOne then
			remaining = 1
		end
		while #species.genomes > remaining do
			table.remove(species.genomes)
		end
	end
end

function breedChild(species)
	local child = {}
	if math.random() < CrossoverChance then
		g1 = species.genomes[math.random(1, #species.genomes)]
		g2 = species.genomes[math.random(1, #species.genomes)]
		child = crossover(g1, g2)
	else
		g = species.genomes[math.random(1, #species.genomes)]
		child = copyGenome(g)
	end
	
	mutate(child)
	
	return child
end

function removeStaleSpecies()
	local survived = {}

	for s = 1,#pool.species do
		local species = pool.species[s]
		
		table.sort(species.genomes, function (a,b)
			return (a.fitness > b.fitness)
		end)
		
		if species.genomes[1].fitness > species.topFitness then
			species.topFitness = species.genomes[1].fitness
			species.staleness = 0
		else
			species.staleness = species.staleness + 1
		end
		if species.staleness < StaleSpecies or species.topFitness >= pool.maxFitness then
			table.insert(survived, species)
		end
	end

	pool.species = survived
end

function removeWeakSpecies()
	local survived = {}

	local sum = totalAverageFitness()
	for s = 1,#pool.species do
		local species = pool.species[s]
		breed = math.floor(species.averageFitness / sum * Population)
		if breed >= 1 then
			table.insert(survived, species)
		end
	end

	pool.species = survived
end


function addToSpecies(child)
	local foundSpecies = false
	for s=1,#pool.species do
		local species = pool.species[s]
		if not foundSpecies and sameSpecies(child, species.genomes[1]) then
			table.insert(species.genomes, child)
			foundSpecies = true
		end
	end
	
	if not foundSpecies then
		local childSpecies = newSpecies()
		table.insert(childSpecies.genomes, child)
		table.insert(pool.species, childSpecies)
	end
end

function newGeneration()
	cullSpecies(false) -- Cull the bottom half of each species
	rankGlobally()
	removeStaleSpecies()
	rankGlobally()
	for s = 1,#pool.species do
		local species = pool.species[s]
		calculateAverageFitness(species)
	end
	removeWeakSpecies()
	local sum = totalAverageFitness()
	local children = {}
	for s = 1,#pool.species do
		local species = pool.species[s]
		breed = math.floor(species.averageFitness / sum * Population) - 1
		for i=1,breed do
			table.insert(children, breedChild(species))
		end
	end
	cullSpecies(true) -- Cull all but the top member of each species
	while #children + #pool.species < Population do
		local species = pool.species[math.random(1, #pool.species)]
		table.insert(children, breedChild(species))
	end
	for c=1,#children do
		local child = children[c]
		addToSpecies(child)
	end
	
	pool.generation = pool.generation + 1
	
	writeFile("backup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
end
	
function initializePool()
	pool = newPool()

	for i=1,Population do
		basic = basicGenome()
		addToSpecies(basic)
	end

	initializeRun()
end

function clearJoypad()
	controller = {}
	for b = 1,#ButtonNames do
		controller["P1 " .. ButtonNames[b]] = false
	end
	joypad.set(controller)
end

function initializeRun()
	savestate.load(Filename);
	rightmost = 0
	pool.currentFrame = 0
	timeout = TimeoutConstant
	clearJoypad()
	
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	generateNetwork(genome)
	evaluateCurrent()
end

function evaluateCurrent()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]

	inputs = getInputs()
	controller = evaluateNetwork(genome.network, inputs)
	
	if controller["P1 Left"] and controller["P1 Right"] then
		controller["P1 Left"] = false
		controller["P1 Right"] = false
	end
	if controller["P1 Up"] and controller["P1 Down"] then
		controller["P1 Up"] = false
		controller["P1 Down"] = false
	end

	joypad.set(controller)
end

if pool == nil then
	initializePool()
end


function nextGenome()
	pool.currentGenome = pool.currentGenome + 1
	if pool.currentGenome > #pool.species[pool.currentSpecies].genomes then
		pool.currentGenome = 1
		pool.currentSpecies = pool.currentSpecies+1
		if pool.currentSpecies > #pool.species then
			newGeneration()
			pool.currentSpecies = 1
		end
	end
end

function fitnessAlreadyMeasured()
	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	
	return genome.fitness ~= 0
end

function displayGenome(genome)
	local network = genome.network
	local cells = {}
	local i = 1
	local cell = {}
	for dy=-BoxRadius,BoxRadius do
		for dx=-BoxRadius,BoxRadius do
			cell = {}
			cell.x = 50+5*dx
			cell.y = 70+5*dy
			cell.value = network.neurons[i].value
			cells[i] = cell
			i = i + 1
		end
	end
	local biasCell = {}
	biasCell.x = 80
	biasCell.y = 110
	biasCell.value = network.neurons[Inputs].value
	cells[Inputs] = biasCell
	
	for o = 1,Outputs do
		cell = {}
		cell.x = 220
		cell.y = 30 + 8 * o
		cell.value = network.neurons[MaxNodes + o].value
		cells[MaxNodes+o] = cell
		local color
		if cell.value > 0 then
			color = 0xFF0000FF
		else
			color = 0xFF000000
		end
		gui.drawText(223, 24+8*o, ButtonNames[o], color, 9)
	end
	
	for n,neuron in pairs(network.neurons) do
		cell = {}
		if n > Inputs and n <= MaxNodes then
			cell.x = 140
			cell.y = 40
			cell.value = neuron.value
			cells[n] = cell
		end
	end
	
	for n=1,4 do
		for _,gene in pairs(genome.genes) do
			if gene.enabled then
				local c1 = cells[gene.into]
				local c2 = cells[gene.out]
				if gene.into > Inputs and gene.into <= MaxNodes then
					c1.x = 0.75*c1.x + 0.25*c2.x
					if c1.x >= c2.x then
						c1.x = c1.x - 40
					end
					if c1.x < 90 then
						c1.x = 90
					end
					
					if c1.x > 220 then
						c1.x = 220
					end
					c1.y = 0.75*c1.y + 0.25*c2.y
					
				end
				if gene.out > Inputs and gene.out <= MaxNodes then
					c2.x = 0.25*c1.x + 0.75*c2.x
					if c1.x >= c2.x then
						c2.x = c2.x + 40
					end
					if c2.x < 90 then
						c2.x = 90
					end
					if c2.x > 220 then
						c2.x = 220
					end
					c2.y = 0.25*c1.y + 0.75*c2.y
				end
			end
		end
	end
	
	gui.drawBox(50-BoxRadius*5-3,70-BoxRadius*5-3,50+BoxRadius*5+2,70+BoxRadius*5+2,0xFF000000, 0x80808080)
	for n,cell in pairs(cells) do
		if n > Inputs or cell.value ~= 0 then
			local color = math.floor((cell.value+1)/2*256)
			if color > 255 then color = 255 end
			if color < 0 then color = 0 end
			local opacity = 0xFF000000
			if cell.value == 0 then
				opacity = 0x50000000
			end
			color = opacity + color*0x10000 + color*0x100 + color
			gui.drawBox(cell.x-2,cell.y-2,cell.x+2,cell.y+2,opacity,color)
		end
	end
	for _,gene in pairs(genome.genes) do
		if gene.enabled then
			local c1 = cells[gene.into]
			local c2 = cells[gene.out]
			local opacity = 0xA0000000
			if c1.value == 0 then
				opacity = 0x20000000
			end
			
			local color = 0x80-math.floor(math.abs(sigmoid(gene.weight))*0x80)
			if gene.weight > 0 then 
				color = opacity + 0x8000 + 0x10000*color
			else
				color = opacity + 0x800000 + 0x100*color
			end
			gui.drawLine(c1.x+1, c1.y, c2.x-3, c2.y, color)
		end
	end
	
	gui.drawBox(49,71,51,78,0x00000000,0x80FF0000)
	
	if forms.ischecked(showMutationRates) then
		local pos = 100
		for mutation,rate in pairs(genome.mutationRates) do
			gui.drawText(100, pos, mutation .. ": " .. rate, 0xFF000000, 10)
			pos = pos + 8
		end
	end
end

function writeFile(filename)
        local file = io.open(filename, "w")
	file:write(pool.generation .. "\n")
	file:write(pool.maxFitness .. "\n")
	file:write(#pool.species .. "\n")
        for n,species in pairs(pool.species) do
		file:write(species.topFitness .. "\n")
		file:write(species.staleness .. "\n")
		file:write(#species.genomes .. "\n")
		for m,genome in pairs(species.genomes) do
			file:write(genome.fitness .. "\n")
			file:write(genome.maxneuron .. "\n")
			for mutation,rate in pairs(genome.mutationRates) do
				file:write(mutation .. "\n")
				file:write(rate .. "\n")
			end
			file:write("done\n")
			
			file:write(#genome.genes .. "\n")
			for l,gene in pairs(genome.genes) do
				file:write(gene.into .. " ")
				file:write(gene.out .. " ")
				file:write(gene.weight .. " ")
				file:write(gene.innovation .. " ")
				if(gene.enabled) then
					file:write("1\n")
				else
					file:write("0\n")
				end
			end
		end
        end
        file:close()
end

function savePool()
	local filename = forms.gettext(saveLoadFile)
	writeFile(filename)
end

function loadFile(filename)
        local file = io.open(filename, "r")
	pool = newPool()
	pool.generation = file:read("*number")
	pool.maxFitness = file:read("*number")
	forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
        local numSpecies = file:read("*number")
        for s=1,numSpecies do
		local species = newSpecies()
		table.insert(pool.species, species)
		species.topFitness = file:read("*number")
		species.staleness = file:read("*number")
		local numGenomes = file:read("*number")
		for g=1,numGenomes do
			local genome = newGenome()
			table.insert(species.genomes, genome)
			genome.fitness = file:read("*number")
			genome.maxneuron = file:read("*number")
			local line = file:read("*line")
			while line ~= "done" do
				genome.mutationRates[line] = file:read("*number")
				line = file:read("*line")
			end
			local numGenes = file:read("*number")
			for n=1,numGenes do
				local gene = newGene()
				table.insert(genome.genes, gene)
				local enabled
				gene.into, gene.out, gene.weight, gene.innovation, enabled = file:read("*number", "*number", "*number", "*number", "*number")
				if enabled == 0 then
					gene.enabled = false
				else
					gene.enabled = true
				end
				
			end
		end
	end
        file:close()
	
	while fitnessAlreadyMeasured() do
		nextGenome()
	end
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
end
 
function loadPool()
	local filename = forms.gettext(saveLoadFile)
	loadFile(filename)
end

function playTop()
	local maxfitness = 0
	local maxs, maxg
	for s,species in pairs(pool.species) do
		for g,genome in pairs(species.genomes) do
			if genome.fitness > maxfitness then
				maxfitness = genome.fitness
				maxs = s
				maxg = g
			end
		end
	end
	
	pool.currentSpecies = maxs
	pool.currentGenome = maxg
	pool.maxFitness = maxfitness
	forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
	initializeRun()
	pool.currentFrame = pool.currentFrame + 1
	return
end

function onExit()
	forms.destroy(form)
end

writeFile("temp.pool")

event.onexit(onExit)

form = forms.newform(200, 260, "Fitness")
maxFitnessLabel = forms.label(form, "Max Fitness: " .. math.floor(pool.maxFitness), 5, 8)
showNetwork = forms.checkbox(form, "Show Map", 5, 30)
showMutationRates = forms.checkbox(form, "Show M-Rates", 5, 52)
restartButton = forms.button(form, "Restart", initializePool, 5, 77)
saveButton = forms.button(form, "Save", savePool, 5, 102)
loadButton = forms.button(form, "Load", loadPool, 80, 102)
saveLoadFile = forms.textbox(form, Filename .. ".pool", 170, 25, nil, 5, 148)
saveLoadLabel = forms.label(form, "Save/Load:", 5, 129)
playTopButton = forms.button(form, "Play Top", playTop, 5, 170)
hideBanner = forms.checkbox(form, "Hide Banner", 5, 190)


while true do
	local backgroundColor = 0xD0FFFFFF
	if not forms.ischecked(hideBanner) then
		gui.drawBox(0, 0, 300, 26, backgroundColor, backgroundColor)
	end

	local species = pool.species[pool.currentSpecies]
	local genome = species.genomes[pool.currentGenome]
	
	if forms.ischecked(showNetwork) then
		displayGenome(genome)
	end
	
	if pool.currentFrame%5 == 0 then
		evaluateCurrent()
	end

	joypad.set(controller)

	getPositions()
	if MegaManX > rightmost then
		rightmost = MegaManX
		timeout = TimeoutConstant
	end
	
	timeout = timeout - 1
	
	
	local timeoutBonus = pool.currentFrame / 4
	if timeout + timeoutBonus <= 0 then
		local fitness = rightmost - pool.currentFrame / 2
		if gameinfo.getromname() == "Super Mario World (USA)" and rightmost > 4816 then
			fitness = fitness + 1000
		end
		if gameinfo.getromname() == "Super Mario Bros." and rightmost > 3186 then
			fitness = fitness + 1000
		end
		if fitness == 0 then
			fitness = -1
		end
		genome.fitness = fitness
		
		if fitness > pool.maxFitness then
			pool.maxFitness = fitness
			forms.settext(maxFitnessLabel, "Max Fitness: " .. math.floor(pool.maxFitness))
			writeFile("backup." .. pool.generation .. "." .. forms.gettext(saveLoadFile))
		end
		
		console.writeline("Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " fitness: " .. fitness)
		pool.currentSpecies = 1
		pool.currentGenome = 1
		while fitnessAlreadyMeasured() do
			nextGenome()
		end
		initializeRun()
	end

	local measured = 0
	local total = 0
	for _,species in pairs(pool.species) do
		for _,genome in pairs(species.genomes) do
			total = total + 1
			if genome.fitness ~= 0 then
				measured = measured + 1
			end
		end
	end
	if not forms.ischecked(hideBanner) then
		gui.drawText(0, 0, "Gen " .. pool.generation .. " species " .. pool.currentSpecies .. " genome " .. pool.currentGenome .. " (" .. math.floor(measured/total*100) .. "%)", 0xFF000000, 11)
		gui.drawText(0, 12, "Fitness: " .. math.floor(rightmost - (pool.currentFrame) / 2 - (timeout + timeoutBonus)*2/3), 0xFF000000, 11)
		gui.drawText(100, 12, "Max Fitness: " .. math.floor(pool.maxFitness), 0xFF000000, 11)
	end
		
	pool.currentFrame = pool.currentFrame + 1

	emu.frameadvance();
end