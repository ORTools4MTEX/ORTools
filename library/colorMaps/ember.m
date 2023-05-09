
function cm = ember(n, varargin)
% Colormap: ember

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
	0.000000000	0.000000000	0.000000000
	0.000173000	0.000195000	0.000257000
	0.000592000	0.000677000	0.000930000
	0.001212000	0.001402000	0.002007000
	0.002016000	0.002348000	0.003499000
	0.003000000	0.003499000	0.005420000
	0.004163000	0.004841000	0.007787000
	0.005512000	0.006361000	0.010619000
	0.007061000	0.008046000	0.013932000
	0.008825000	0.009883000	0.017741000
	0.010826000	0.011858000	0.022057000
	0.013090000	0.013957000	0.026886000
	0.015645000	0.016166000	0.032227000
	0.018519000	0.018471000	0.038073000
	0.021744000	0.020861000	0.044238000
	0.025348000	0.023325000	0.050318000
	0.029359000	0.025851000	0.056300000
	0.033801000	0.028433000	0.062179000
	0.038695000	0.031063000	0.067949000
	0.043914000	0.033735000	0.073609000
	0.049196000	0.036443000	0.079158000
	0.054540000	0.039184000	0.084596000
	0.059940000	0.041911000	0.089926000
	0.065390000	0.044547000	0.095152000
	0.070886000	0.047107000	0.100277000
	0.076422000	0.049592000	0.105303000
	0.081996000	0.052007000	0.110234000
	0.087605000	0.054354000	0.115074000
	0.093247000	0.056635000	0.119826000
	0.098920000	0.058852000	0.124492000
	0.104622000	0.061007000	0.129074000
	0.110353000	0.063101000	0.133576000
	0.116110000	0.065136000	0.137998000
	0.121894000	0.067112000	0.142343000
	0.127703000	0.069032000	0.146612000
	0.133538000	0.070895000	0.150807000
	0.139397000	0.072702000	0.154929000
	0.145280000	0.074455000	0.158979000
	0.151186000	0.076154000	0.162958000
	0.157115000	0.077799000	0.166866000
	0.163068000	0.079392000	0.170704000
	0.169043000	0.080932000	0.174473000
	0.175040000	0.082419000	0.178174000
	0.181059000	0.083856000	0.181806000
	0.187100000	0.085240000	0.185371000
	0.193162000	0.086574000	0.188867000
	0.199246000	0.087856000	0.192297000
	0.205351000	0.089088000	0.195659000
	0.211476000	0.090269000	0.198954000
	0.217622000	0.091400000	0.202182000
	0.223788000	0.092480000	0.205343000
	0.229975000	0.093509000	0.208437000
	0.236181000	0.094489000	0.211464000
	0.242407000	0.095417000	0.214423000
	0.248653000	0.096296000	0.217316000
	0.254918000	0.097123000	0.220141000
	0.261202000	0.097900000	0.222898000
	0.267506000	0.098626000	0.225588000
	0.273828000	0.099300000	0.228209000
	0.280168000	0.099923000	0.230762000
	0.286527000	0.100495000	0.233247000
	0.292904000	0.101014000	0.235662000
	0.299299000	0.101482000	0.238008000
	0.305712000	0.101896000	0.240285000
	0.312142000	0.102258000	0.242491000
	0.318589000	0.102566000	0.244627000
	0.325054000	0.102820000	0.246692000
	0.331535000	0.103020000	0.248686000
	0.338033000	0.103165000	0.250607000
	0.344547000	0.103255000	0.252456000
	0.351077000	0.103288000	0.254232000
	0.357623000	0.103266000	0.255935000
	0.364184000	0.103186000	0.257563000
	0.370760000	0.103048000	0.259117000
	0.377351000	0.102852000	0.260594000
	0.383957000	0.102597000	0.261996000
	0.390576000	0.102282000	0.263321000
	0.397209000	0.101906000	0.264568000
	0.403856000	0.101469000	0.265737000
	0.410516000	0.100971000	0.266827000
	0.417188000	0.100409000	0.267836000
	0.423872000	0.099784000	0.268765000
	0.430567000	0.099094000	0.269613000
	0.437274000	0.098339000	0.270378000
	0.443991000	0.097518000	0.271059000
	0.450718000	0.096630000	0.271656000
	0.457454000	0.095674000	0.272168000
	0.464199000	0.094650000	0.272594000
	0.470952000	0.093557000	0.272932000
	0.477712000	0.092394000	0.273183000
	0.484479000	0.091160000	0.273344000
	0.491251000	0.089855000	0.273414000
	0.498028000	0.088478000	0.273394000
	0.504809000	0.087029000	0.273280000
	0.511593000	0.085508000	0.273074000
	0.518379000	0.083915000	0.272772000
	0.525166000	0.082249000	0.272375000
	0.531953000	0.080512000	0.271881000
	0.538737000	0.078704000	0.271289000
	0.545519000	0.076827000	0.270598000
	0.552297000	0.074881000	0.269806000
	0.559068000	0.072870000	0.268913000
	0.565833000	0.070796000	0.267918000
	0.572588000	0.068664000	0.266819000
	0.579332000	0.066477000	0.265616000
	0.586063000	0.064244000	0.264308000
	0.592780000	0.061970000	0.262893000
	0.599479000	0.059667000	0.261372000
	0.606159000	0.057345000	0.259742000
	0.612818000	0.055019000	0.258005000
	0.619451000	0.052706000	0.256159000
	0.626058000	0.050427000	0.254203000
	0.632635000	0.048208000	0.252139000
	0.639179000	0.046077000	0.249965000
	0.645686000	0.044067000	0.247684000
	0.652154000	0.042219000	0.245294000
	0.658579000	0.040575000	0.242797000
	0.664957000	0.039175000	0.240194000
	0.671284000	0.038099000	0.237487000
	0.677557000	0.037385000	0.234677000
	0.683771000	0.037071000	0.231769000
	0.689923000	0.037196000	0.228763000
	0.696009000	0.037799000	0.225664000
	0.702023000	0.038923000	0.222475000
	0.707963000	0.040605000	0.219201000
	0.713823000	0.042815000	0.215847000
	0.719601000	0.045551000	0.212417000
	0.725292000	0.048791000	0.208919000
	0.730893000	0.052504000	0.205357000
	0.736401000	0.056656000	0.201739000
	0.741813000	0.061208000	0.198071000
	0.747127000	0.066120000	0.194361000
	0.752339000	0.071352000	0.190614000
	0.757450000	0.076868000	0.186839000
	0.762457000	0.082631000	0.183042000
	0.767360000	0.088611000	0.179230000
	0.772158000	0.094777000	0.175409000
	0.776852000	0.101103000	0.171585000
	0.781443000	0.107565000	0.167764000
	0.785931000	0.114141000	0.163951000
	0.790317000	0.120813000	0.160149000
	0.794605000	0.127563000	0.156364000
	0.798794000	0.134378000	0.152598000
	0.802888000	0.141243000	0.148854000
	0.806889000	0.148148000	0.145134000
	0.810800000	0.155083000	0.141439000
	0.814622000	0.162039000	0.137772000
	0.818358000	0.169008000	0.134132000
	0.822012000	0.175986000	0.130519000
	0.825585000	0.182965000	0.126934000
	0.829080000	0.189941000	0.123375000
	0.832500000	0.196911000	0.119843000
	0.835847000	0.203872000	0.116336000
	0.839123000	0.210820000	0.112853000
	0.842330000	0.217755000	0.109392000
	0.845472000	0.224673000	0.105952000
	0.848549000	0.231573000	0.102531000
	0.851565000	0.238455000	0.099128000
	0.854519000	0.245319000	0.095740000
	0.857416000	0.252162000	0.092365000
	0.860255000	0.258986000	0.089002000
	0.863039000	0.265789000	0.085649000
	0.865769000	0.272573000	0.082303000
	0.868447000	0.279337000	0.078963000
	0.871073000	0.286081000	0.075626000
	0.873650000	0.292806000	0.072291000
	0.876177000	0.299512000	0.068957000
	0.878657000	0.306199000	0.065620000
	0.881090000	0.312869000	0.062279000
	0.883478000	0.319521000	0.058934000
	0.885820000	0.326157000	0.055580000
	0.888118000	0.332776000	0.052219000
	0.890373000	0.339380000	0.048848000
	0.892585000	0.345969000	0.045466000
	0.894755000	0.352544000	0.042070000
	0.896884000	0.359105000	0.038657000
	0.898971000	0.365654000	0.035355000
	0.901018000	0.372190000	0.032211000
	0.903026000	0.378714000	0.029227000
	0.904993000	0.385228000	0.026401000
	0.906922000	0.391731000	0.023734000
	0.908811000	0.398225000	0.021226000
	0.910662000	0.404709000	0.018879000
	0.912476000	0.411184000	0.016695000
	0.914251000	0.417652000	0.014674000
	0.915988000	0.424113000	0.012817000
	0.917688000	0.430567000	0.011129000
	0.919351000	0.437014000	0.009609000
	0.920977000	0.443456000	0.008262000
	0.922566000	0.449893000	0.007090000
	0.924118000	0.456325000	0.006096000
	0.925633000	0.462753000	0.005284000
	0.927112000	0.469177000	0.004656000
	0.928554000	0.475598000	0.004216000
	0.929960000	0.482017000	0.003969000
	0.931329000	0.488433000	0.003919000
	0.932663000	0.494848000	0.004071000
	0.933959000	0.501261000	0.004428000
	0.935220000	0.507673000	0.004995000
	0.936444000	0.514084000	0.005778000
	0.937631000	0.520496000	0.006782000
	0.938783000	0.526907000	0.008012000
	0.939898000	0.533319000	0.009474000
	0.940976000	0.539732000	0.011173000
	0.942018000	0.546147000	0.013116000
	0.943024000	0.552562000	0.015309000
	0.943992000	0.558980000	0.017758000
	0.944924000	0.565401000	0.020469000
	0.945819000	0.571823000	0.023450000
	0.946677000	0.578249000	0.026707000
	0.947499000	0.584677000	0.030248000
	0.948283000	0.591109000	0.034078000
	0.949030000	0.597545000	0.038206000
	0.949740000	0.603985000	0.042570000
	0.950413000	0.610429000	0.046956000
	0.951048000	0.616877000	0.051364000
	0.951645000	0.623331000	0.055792000
	0.952205000	0.629788000	0.060241000
	0.952726000	0.636252000	0.064707000
	0.953210000	0.642720000	0.069193000
	0.953655000	0.649194000	0.073695000
	0.954063000	0.655674000	0.078216000
	0.954431000	0.662160000	0.082754000
	0.954762000	0.668652000	0.087309000
	0.955053000	0.675151000	0.091881000
	0.955305000	0.681656000	0.096471000
	0.955519000	0.688168000	0.101077000
	0.955692000	0.694688000	0.105701000
	0.955827000	0.701214000	0.110342000
	0.955922000	0.707747000	0.115000000
	0.955976000	0.714289000	0.119675000
	0.955991000	0.720838000	0.124368000
	0.955965000	0.727395000	0.129077000
	0.955899000	0.733960000	0.133803000
	0.955792000	0.740534000	0.138547000
	0.955643000	0.747116000	0.143307000
	0.955453000	0.753707000	0.148084000
	0.955221000	0.760307000	0.152879000
	0.954947000	0.766916000	0.157690000
	0.954630000	0.773535000	0.162518000
	0.954271000	0.780163000	0.167362000
	0.953868000	0.786801000	0.172223000
	0.953421000	0.793449000	0.177101000
	0.952931000	0.800107000	0.181995000
	0.952396000	0.806776000	0.186905000
	0.951816000	0.813456000	0.191831000
	0.951189000	0.820146000	0.196773000
	0.950517000	0.826848000	0.201732000
	0.949798000	0.833561000	0.206706000
	0.949032000	0.840286000	0.211695000
	0.948217000	0.847023000	0.216701000
	0.947354000	0.853772000	0.221722000
	0.946441000	0.860534000	0.226758000
	0.945477000	0.867309000	0.231809000
	0.944463000	0.874096000	0.236876000
	0.943395000	0.880898000	0.241958000
];

% Modify the colormap by interpolation to match number of waypoints.
cm = tools.interpolate(cm, n, varargin{:});

end