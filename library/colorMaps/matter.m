
function cm = matter(n, varargin)
% Colormap: matter

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
	0.185172000	0.059133000	0.243043000
	0.190082000	0.060579000	0.246516000
	0.195002000	0.061990000	0.249968000
	0.199930000	0.063368000	0.253398000
	0.204869000	0.064711000	0.256805000
	0.209824000	0.066015000	0.260191000
	0.214788000	0.067286000	0.263551000
	0.219762000	0.068526000	0.266888000
	0.224746000	0.069734000	0.270198000
	0.229745000	0.070906000	0.273483000
	0.234755000	0.072046000	0.276741000
	0.239776000	0.073156000	0.279971000
	0.244807000	0.074236000	0.283172000
	0.249849000	0.075288000	0.286344000
	0.254905000	0.076306000	0.289486000
	0.259972000	0.077294000	0.292597000
	0.265050000	0.078255000	0.295676000
	0.270139000	0.079188000	0.298722000
	0.275238000	0.080094000	0.301734000
	0.280348000	0.080974000	0.304712000
	0.285468000	0.081828000	0.307654000
	0.290601000	0.082653000	0.310560000
	0.295745000	0.083454000	0.313428000
	0.300898000	0.084231000	0.316257000
	0.306061000	0.084985000	0.319048000
	0.311234000	0.085716000	0.321798000
	0.316417000	0.086425000	0.324506000
	0.321608000	0.087114000	0.327172000
	0.326809000	0.087783000	0.329795000
	0.332019000	0.088432000	0.332374000
	0.337237000	0.089063000	0.334907000
	0.342463000	0.089678000	0.337393000
	0.347697000	0.090276000	0.339832000
	0.352939000	0.090859000	0.342223000
	0.358188000	0.091428000	0.344564000
	0.363444000	0.091985000	0.346855000
	0.368706000	0.092530000	0.349094000
	0.373974000	0.093066000	0.351280000
	0.379247000	0.093593000	0.353414000
	0.384526000	0.094114000	0.355492000
	0.389809000	0.094629000	0.357516000
	0.395095000	0.095141000	0.359483000
	0.400385000	0.095651000	0.361394000
	0.405678000	0.096160000	0.363246000
	0.410973000	0.096672000	0.365040000
	0.416270000	0.097187000	0.366775000
	0.421568000	0.097707000	0.368450000
	0.426866000	0.098234000	0.370064000
	0.432165000	0.098770000	0.371616000
	0.437464000	0.099316000	0.373105000
	0.442761000	0.099875000	0.374533000
	0.448056000	0.100449000	0.375897000
	0.453349000	0.101040000	0.377199000
	0.458638000	0.101651000	0.378437000
	0.463923000	0.102283000	0.379612000
	0.469206000	0.102936000	0.380721000
	0.474482000	0.103615000	0.381766000
	0.479753000	0.104321000	0.382748000
	0.485018000	0.105056000	0.383665000
	0.490276000	0.105822000	0.384519000
	0.495527000	0.106618000	0.385308000
	0.500769000	0.107450000	0.386033000
	0.506003000	0.108318000	0.386696000
	0.511228000	0.109223000	0.387296000
	0.516443000	0.110166000	0.387832000
	0.521648000	0.111150000	0.388308000
	0.526842000	0.112176000	0.388722000
	0.532025000	0.113245000	0.389075000
	0.537196000	0.114356000	0.389368000
	0.542355000	0.115514000	0.389603000
	0.547501000	0.116717000	0.389779000
	0.552635000	0.117966000	0.389897000
	0.557755000	0.119263000	0.389959000
	0.562861000	0.120608000	0.389966000
	0.567953000	0.122000000	0.389917000
	0.573030000	0.123441000	0.389815000
	0.578092000	0.124932000	0.389661000
	0.583140000	0.126472000	0.389455000
	0.588172000	0.128061000	0.389198000
	0.593187000	0.129699000	0.388893000
	0.598187000	0.131387000	0.388539000
	0.603171000	0.133124000	0.388137000
	0.608138000	0.134911000	0.387691000
	0.613088000	0.136746000	0.387199000
	0.618021000	0.138630000	0.386663000
	0.622936000	0.140563000	0.386085000
	0.627835000	0.142544000	0.385465000
	0.632715000	0.144572000	0.384805000
	0.637577000	0.146649000	0.384106000
	0.642421000	0.148773000	0.383369000
	0.647246000	0.150944000	0.382595000
	0.652052000	0.153162000	0.381784000
	0.656840000	0.155426000	0.380939000
	0.661608000	0.157737000	0.380061000
	0.666356000	0.160093000	0.379149000
	0.671084000	0.162495000	0.378207000
	0.675792000	0.164943000	0.377234000
	0.680479000	0.167435000	0.376231000
	0.685145000	0.169973000	0.375200000
	0.689790000	0.172556000	0.374142000
	0.694412000	0.175184000	0.373058000
	0.699013000	0.177857000	0.371949000
	0.703590000	0.180574000	0.370817000
	0.708144000	0.183336000	0.369661000
	0.712674000	0.186143000	0.368485000
	0.717180000	0.188996000	0.367287000
	0.721661000	0.191893000	0.366072000
	0.726116000	0.194835000	0.364838000
	0.730545000	0.197823000	0.363587000
	0.734946000	0.200857000	0.362322000
	0.739320000	0.203937000	0.361042000
	0.743666000	0.207064000	0.359751000
	0.747981000	0.210237000	0.358448000
	0.752267000	0.213457000	0.357137000
	0.756521000	0.216724000	0.355817000
	0.760744000	0.220040000	0.354492000
	0.764933000	0.223404000	0.353162000
	0.769088000	0.226817000	0.351830000
	0.773208000	0.230279000	0.350498000
	0.777292000	0.233790000	0.349167000
	0.781339000	0.237352000	0.347839000
	0.785347000	0.240965000	0.346518000
	0.789316000	0.244628000	0.345205000
	0.793244000	0.248344000	0.343903000
	0.797130000	0.252111000	0.342614000
	0.800973000	0.255930000	0.341341000
	0.804772000	0.259802000	0.340086000
	0.808525000	0.263726000	0.338854000
	0.812231000	0.267704000	0.337645000
	0.815890000	0.271734000	0.336464000
	0.819499000	0.275818000	0.335314000
	0.823058000	0.279955000	0.334198000
	0.826566000	0.284144000	0.333120000
	0.830022000	0.288387000	0.332082000
	0.833425000	0.292681000	0.331088000
	0.836774000	0.297028000	0.330142000
	0.840068000	0.301426000	0.329246000
	0.843306000	0.305874000	0.328407000
	0.846488000	0.310372000	0.327624000
	0.849614000	0.314919000	0.326903000
	0.852682000	0.319514000	0.326248000
	0.855693000	0.324156000	0.325659000
	0.858647000	0.328843000	0.325143000
	0.861543000	0.333573000	0.324701000
	0.864381000	0.338347000	0.324334000
	0.867163000	0.343161000	0.324049000
	0.869888000	0.348014000	0.323846000
	0.872556000	0.352906000	0.323726000
	0.875167000	0.357833000	0.323693000
	0.877725000	0.362793000	0.323749000
	0.880227000	0.367787000	0.323895000
	0.882676000	0.372812000	0.324130000
	0.885071000	0.377865000	0.324458000
	0.887416000	0.382944000	0.324881000
	0.889710000	0.388049000	0.325396000
	0.891954000	0.393178000	0.326005000
	0.894148000	0.398329000	0.326707000
	0.896296000	0.403501000	0.327504000
	0.898398000	0.408689000	0.328396000
	0.900456000	0.413895000	0.329381000
	0.902469000	0.419117000	0.330459000
	0.904439000	0.424354000	0.331628000
	0.906368000	0.429605000	0.332888000
	0.908257000	0.434867000	0.334239000
	0.910106000	0.440140000	0.335678000
	0.911918000	0.445423000	0.337206000
	0.913692000	0.450714000	0.338819000
	0.915431000	0.456014000	0.340519000
	0.917136000	0.461320000	0.342301000
	0.918807000	0.466632000	0.344167000
	0.920445000	0.471950000	0.346113000
	0.922052000	0.477272000	0.348138000
	0.923629000	0.482598000	0.350241000
	0.925175000	0.487928000	0.352419000
	0.926693000	0.493262000	0.354673000
	0.928181000	0.498598000	0.356999000
	0.929643000	0.503937000	0.359396000
	0.931076000	0.509278000	0.361863000
	0.932483000	0.514622000	0.364398000
	0.933866000	0.519967000	0.367000000
	0.935228000	0.525310000	0.369668000
	0.936566000	0.530654000	0.372399000
	0.937878000	0.536000000	0.375192000
	0.939167000	0.541348000	0.378047000
	0.940431000	0.546697000	0.380961000
	0.941678000	0.552045000	0.383933000
	0.942907000	0.557390000	0.386962000
	0.944112000	0.562738000	0.390046000
	0.945294000	0.568088000	0.393186000
	0.946455000	0.573439000	0.396378000
	0.947606000	0.578783000	0.399622000
	0.948735000	0.584131000	0.402917000
	0.949840000	0.589482000	0.406262000
	0.950930000	0.594832000	0.409656000
	0.952008000	0.600178000	0.413097000
	0.953063000	0.605528000	0.416585000
	0.954095000	0.610882000	0.420120000
	0.955125000	0.616226000	0.423698000
	0.956132000	0.621576000	0.427321000
	0.957114000	0.626932000	0.430989000
	0.958096000	0.632279000	0.434696000
	0.959056000	0.637631000	0.438446000
	0.959992000	0.642988000	0.442239000
	0.960929000	0.648337000	0.446068000
	0.961842000	0.653692000	0.449939000
	0.962738000	0.659050000	0.453850000
	0.963630000	0.664403000	0.457796000
	0.964496000	0.669765000	0.461784000
	0.965358000	0.675123000	0.465805000
	0.966203000	0.680483000	0.469865000
	0.967027000	0.685850000	0.473962000
	0.967853000	0.691210000	0.478091000
	0.968650000	0.696581000	0.482260000
	0.969448000	0.701946000	0.486459000
	0.970226000	0.707317000	0.490695000
	0.970991000	0.712691000	0.494965000
	0.971750000	0.718064000	0.499268000
	0.972484000	0.723446000	0.503607000
	0.973224000	0.728821000	0.507974000
	0.973931000	0.734210000	0.512380000
	0.974649000	0.739590000	0.516812000
	0.975338000	0.744983000	0.521282000
	0.976029000	0.750371000	0.525780000
	0.976698000	0.755768000	0.530313000
	0.977365000	0.761164000	0.534875000
	0.978015000	0.766566000	0.539471000
	0.978658000	0.771970000	0.544097000
	0.979289000	0.777378000	0.548754000
	0.979912000	0.782789000	0.553443000
	0.980524000	0.788204000	0.558162000
	0.981127000	0.793622000	0.562912000
	0.981721000	0.799045000	0.567694000
	0.982307000	0.804470000	0.572504000
	0.982882000	0.809901000	0.577347000
	0.983454000	0.815332000	0.582218000
	0.984010000	0.820772000	0.587122000
	0.984569000	0.826210000	0.592051000
	0.985107000	0.831659000	0.597017000
	0.985656000	0.837103000	0.602004000
	0.986177000	0.842562000	0.607030000
	0.986718000	0.848012000	0.612074000
	0.987228000	0.853478000	0.617159000
	0.987758000	0.858937000	0.622261000
	0.988265000	0.864408000	0.627400000
	0.988780000	0.869878000	0.632561000
	0.989286000	0.875354000	0.637753000
	0.989787000	0.880835000	0.642973000
	0.990295000	0.886316000	0.648216000
	0.990783000	0.891809000	0.653494000
	0.991296000	0.897294000	0.658786000
	0.991784000	0.902793000	0.664115000
	0.992294000	0.908288000	0.669459000
	0.992792000	0.913792000	0.674833000
	0.993292000	0.919299000	0.680231000
	0.993803000	0.924807000	0.685647000
	0.994294000	0.930328000	0.691097000
];

% Modify the colormap by interpolation to match number of waypoints.
cm = tools.interpolate(cm, n, varargin{:});

end