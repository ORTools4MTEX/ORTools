
function cm = hawaii(n, varargin)
% Colormap: hawaii

%-- Parse inputs ---------------------------------------------------------%
if ~exist('n', 'var'); n = []; end
if isempty(n)
   f = get(groot,'CurrentFigure');
   if isempty(f)
      n = size(get(groot,'DefaultFigureColormap'),1);
   else
      n = size(f.Colormap,1);
   end
end
%-------------------------------------------------------------------------%

% Data for colormap:
cm = [
	0.550541462	0.006841975	0.451980320
	0.551493852	0.015366632	0.447971802
	0.552425527	0.023795283	0.443997778
	0.553328174	0.032329013	0.440020648
	0.554227435	0.041169969	0.436063248
	0.555097512	0.049286476	0.432125408
	0.555947642	0.056666762	0.428187639
	0.556797443	0.063524964	0.424271854
	0.557618964	0.069970111	0.420377426
	0.558414593	0.076027750	0.416508592
	0.559210262	0.081935814	0.412663372
	0.559990553	0.087507471	0.408822822
	0.560745784	0.092811114	0.405011952
	0.561494735	0.098080962	0.401237428
	0.562235313	0.103128272	0.397471471
	0.562953563	0.108004635	0.393735859
	0.563662731	0.112871987	0.390024722
	0.564354924	0.117529988	0.386343764
	0.565032048	0.122122432	0.382698451
	0.565708824	0.126681150	0.379073726
	0.566379743	0.131170934	0.375473681
	0.567037306	0.135541995	0.371904522
	0.567679319	0.139871526	0.368377912
	0.568312435	0.144198387	0.364860975
	0.568939221	0.148415579	0.361384071
	0.569558604	0.152618161	0.357941863
	0.570171191	0.156805697	0.354518922
	0.570777386	0.160934097	0.351127216
	0.571377202	0.165008118	0.347763622
	0.571972086	0.169119770	0.344416607
	0.572561762	0.173131126	0.341120273
	0.573141500	0.177165647	0.337836254
	0.573711276	0.181137719	0.334601616
	0.574275629	0.185150542	0.331356475
	0.574839899	0.189094640	0.328169643
	0.575406265	0.193035151	0.324992390
	0.575967434	0.196977724	0.321854270
	0.576518374	0.200854454	0.318739693
	0.577059582	0.204782597	0.315654190
	0.577596113	0.208663546	0.312564974
	0.578135067	0.212544566	0.309541952
	0.578675691	0.216430915	0.306515661
	0.579213822	0.220287488	0.303496031
	0.579746119	0.224106490	0.300517715
	0.580271416	0.227976902	0.297565995
	0.580793440	0.231817189	0.294618109
	0.581314787	0.235645949	0.291714539
	0.581834807	0.239462773	0.288810193
	0.582353171	0.243267848	0.285909641
	0.582870346	0.247097402	0.283065794
	0.583386465	0.250915957	0.280201416
	0.583901367	0.254738946	0.277380871
	0.584415735	0.258530941	0.274551912
	0.584930505	0.262341723	0.271739628
	0.585443370	0.266155937	0.268980136
	0.585951044	0.269966001	0.266197550
	0.586455579	0.273770930	0.263439337
	0.586960633	0.277575249	0.260676067
	0.587466415	0.281373692	0.257925228
	0.587972150	0.285180064	0.255220953
	0.588477978	0.289012944	0.252493884
	0.588984249	0.292818136	0.249766743
	0.589491125	0.296651557	0.247081150
	0.589998664	0.300465363	0.244375616
	0.590506749	0.304299568	0.241715810
	0.591015582	0.308135190	0.239031052
	0.591526217	0.311968821	0.236379229
	0.592038204	0.315845713	0.233692135
	0.592547944	0.319698173	0.231058221
	0.593054503	0.323558741	0.228419744
	0.593561598	0.327428985	0.225772611
	0.594071216	0.331309145	0.223134387
	0.594582623	0.335228996	0.220509974
	0.595095334	0.339130521	0.217865050
	0.595609356	0.343047831	0.215225912
	0.596125508	0.346976093	0.212612856
	0.596644864	0.350920546	0.209994022
	0.597164341	0.354880024	0.207388202
	0.597679601	0.358829829	0.204776124
	0.598196014	0.362821077	0.202147404
	0.598720839	0.366829002	0.199533155
	0.599248296	0.370836736	0.196964352
	0.599771367	0.374878805	0.194370229
	0.600293617	0.378931432	0.191738266
	0.600818841	0.383008964	0.189148720
	0.601346052	0.387089703	0.186548447
	0.601874160	0.391215230	0.183949277
	0.602403040	0.395345469	0.181344687
	0.602932986	0.399486365	0.178782456
	0.603464443	0.403678347	0.176158027
	0.603995035	0.407872897	0.173594119
	0.604520935	0.412101738	0.171014674
	0.605042567	0.416348170	0.168436467
	0.605562493	0.420617709	0.165847848
	0.606084243	0.424928096	0.163316981
	0.606609004	0.429251948	0.160730825
	0.607129181	0.433600038	0.158195422
	0.607639488	0.437998043	0.155648554
	0.608144144	0.442412104	0.153085850
	0.608644364	0.446848181	0.150581629
	0.609133752	0.451324001	0.148070733
	0.609610114	0.455825846	0.145614995
	0.610079085	0.460355741	0.143119295
	0.610541926	0.464933107	0.140685317
	0.610991194	0.469543503	0.138267026
	0.611421251	0.474170292	0.135829307
	0.611832642	0.478839403	0.133514376
	0.612226047	0.483538917	0.131211510
	0.612599534	0.488287352	0.128919913
	0.612950115	0.493049399	0.126718332
	0.613274970	0.497875043	0.124574285
	0.613571559	0.502704911	0.122486555
	0.613837199	0.507591842	0.120512450
	0.614069000	0.512501544	0.118668512
	0.614263846	0.517459134	0.116848051
	0.614418488	0.522433629	0.115160079
	0.614529574	0.527455598	0.113656751
	0.614593652	0.532510314	0.112265536
	0.614607170	0.537594646	0.111032228
	0.614566482	0.542707647	0.109999232
	0.614467865	0.547848705	0.109114236
	0.614307547	0.553015723	0.108421445
	0.614081750	0.558211681	0.108010235
	0.613786756	0.563446234	0.107850455
	0.613418885	0.568681554	0.107942855
	0.612974310	0.573946000	0.108311962
	0.612449232	0.579232398	0.109026062
	0.611841557	0.584522245	0.110039598
	0.611147514	0.589819578	0.111320085
	0.610353275	0.595132498	0.112963125
	0.609471454	0.600443353	0.114855729
	0.608493920	0.605748082	0.117169222
	0.607410844	0.611059688	0.119810904
	0.606215390	0.616349507	0.122763235
	0.604929798	0.621618369	0.126123754
	0.603535852	0.626876217	0.129756809
	0.602026033	0.632107382	0.133692089
	0.600412703	0.637306340	0.137967077
	0.598689483	0.642469236	0.142496461
	0.596861709	0.647588048	0.147334259
	0.594915711	0.652661917	0.152416391
	0.592872222	0.657697203	0.157790163
	0.590707023	0.662667361	0.163419483
	0.588441281	0.667579062	0.169258241
	0.586084799	0.672428962	0.175280242
	0.583612532	0.677213315	0.181506635
	0.581049131	0.681916148	0.187985117
	0.578387991	0.686560211	0.194585648
	0.575646435	0.691120697	0.201309876
	0.572808890	0.695614001	0.208243350
	0.569878158	0.700018129	0.215284650
	0.566887530	0.704345931	0.222469833
	0.563814439	0.708596676	0.229737591
	0.560662368	0.712752780	0.237171041
	0.557457968	0.716844556	0.244622220
	0.554182044	0.720838870	0.252219228
	0.550852873	0.724766144	0.259873786
	0.547469669	0.728604736	0.267574390
	0.544043055	0.732375865	0.275394003
	0.540571354	0.736057521	0.283238054
	0.537066610	0.739684910	0.291141484
	0.533507016	0.743228081	0.299093693
	0.529935827	0.746702034	0.307079285
	0.526332680	0.750111911	0.315112739
	0.522696180	0.753460927	0.323192431
	0.519048858	0.756752342	0.331280531
	0.515367303	0.759983289	0.339437301
	0.511680931	0.763162119	0.347595474
	0.507990201	0.766293158	0.355784556
	0.504279991	0.769371507	0.363984157
	0.500550215	0.772410230	0.372216995
	0.496819875	0.775405153	0.380484601
	0.493085201	0.778364523	0.388763118
	0.489350258	0.781287451	0.397049267
	0.485614048	0.784180077	0.405376386
	0.481883536	0.787038034	0.413710855
	0.478141755	0.789866173	0.422056965
	0.474411458	0.792673554	0.430439990
	0.470679811	0.795455133	0.438823671
	0.466954590	0.798218835	0.447235268
	0.463220239	0.800964001	0.455667288
	0.459518227	0.803692704	0.464121413
	0.455809909	0.806408929	0.472576991
	0.452123832	0.809109681	0.481054272
	0.448435641	0.811796345	0.489554788
	0.444771780	0.814472161	0.498091019
	0.441108402	0.817143675	0.506616255
	0.437486939	0.819803081	0.515174776
	0.433858366	0.822464676	0.523754784
	0.430280475	0.825110127	0.532352409
	0.426720421	0.827755501	0.540960492
	0.423186438	0.830400501	0.549597666
	0.419707646	0.833036083	0.558241487
	0.416257192	0.835672572	0.566923292
	0.412868214	0.838305041	0.575612496
	0.409520036	0.840937174	0.584314496
	0.406244918	0.843562065	0.593044264
	0.403035402	0.846189662	0.601780125
	0.399904656	0.848818628	0.610540769
	0.396871843	0.851438766	0.619319712
	0.393950441	0.854061402	0.628104344
	0.391152413	0.856682571	0.636905064
	0.388472339	0.859300584	0.645709464
	0.385934608	0.861917508	0.654530182
	0.383585365	0.864525680	0.663366598
	0.381406845	0.867127733	0.672195867
	0.379423563	0.869727539	0.681022835
	0.377671600	0.872324955	0.689862809
	0.376170284	0.874906880	0.698686034
	0.374922969	0.877482003	0.707507060
	0.373981129	0.880045488	0.716318357
	0.373339877	0.882596151	0.725105668
	0.373043052	0.885136276	0.733865228
	0.373111654	0.887653760	0.742601070
	0.373570400	0.890156464	0.751299977
	0.374438963	0.892638558	0.759945501
	0.375722870	0.895095181	0.768546422
	0.377466653	0.897523994	0.777098133
	0.379671128	0.899922679	0.785571851
	0.382352388	0.902288473	0.793974397
	0.385527260	0.904619285	0.802283355
	0.389213226	0.906913438	0.810502756
	0.393384828	0.909161316	0.818619017
	0.398074146	0.911368651	0.826627184
	0.403255024	0.913528442	0.834507419
	0.408925920	0.915628475	0.842255382
	0.415083013	0.917687892	0.849858996
	0.421703753	0.919678419	0.857309297
	0.428790663	0.921614901	0.864605531
	0.436305035	0.923488891	0.871734410
	0.444231193	0.925292897	0.878682304
	0.452541407	0.927032266	0.885453766
	0.461202549	0.928704570	0.892037382
	0.470210853	0.930311033	0.898423803
	0.479521324	0.931838844	0.904619558
	0.489103023	0.933296838	0.910616929
	0.498949543	0.934685138	0.916408460
	0.509018701	0.936004201	0.922005450
	0.519280961	0.937246257	0.927393563
	0.529715141	0.938415723	0.932588370
	0.540291997	0.939516893	0.937591650
	0.550996588	0.940548820	0.942401120
	0.561803745	0.941509045	0.947019726
	0.572686384	0.942411043	0.951458922
	0.583620942	0.943243461	0.955727789
	0.594606038	0.944015297	0.959824981
	0.605610108	0.944730608	0.963765121
	0.616636639	0.945387731	0.967562806
	0.627648146	0.945988540	0.971214176
	0.638645256	0.946542570	0.974738600
	0.649619971	0.947051815	0.978145887
	0.660547913	0.947514676	0.981448787
	0.671439228	0.947934402	0.984652992
	0.682275549	0.948315853	0.987765197
	0.693063985	0.948662476	0.990802879
	0.703778749	0.948976597	0.993774981
];

% Modify the colormap by interpolation to match number of waypoints.
cm = tools.interpolate(cm, n, varargin{:});

end
