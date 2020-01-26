# using Pkg; Pkg.add("JSON")
using JSON

function mutuallyExclusiveGroup_handler(argsIn)
    # mutuallyExclusiveGroup handler
    # replaces that with the first option for the snippet
    if length(argsIn) > 1
        for (iArg, argsInElm) in enumerate(argsIn)
            if haskey(argsInElm, "mutuallyExclusiveGroup")
                options = argsInElm["mutuallyExclusiveGroup"]
                if options[1] isa Vector
                    deleteat!(argsIn, iArg)
                    insert_serial!(argsIn, iArg, options[1])
                else
                    deleteat!(argsIn, iArg)
                    insert_serial!(argsIn, iArg, [options[1]])
                end
            end
        end
    elseif length(argsIn) == 1
        if haskey(argsIn[1], "mutuallyExclusiveGroup")
            options = argsIn[1]["mutuallyExclusiveGroup"]
            if options[1] isa Vector
                argsIn = options[1]
            else
                argsIn = [options[1]]
            end
        end
    end

    return argsIn
end

function insert_serial!(A::Vector, index::Integer, item::Vector)
    itemlen = length(item)
    for i=1:itemlen
        insert!(A, index+(i-1), item[i])
    end
end

function matlab2atom(data)
    final = """
    # MATLAB snippets generated using https://github.com/aminya/Matlab-Snippets
    '.source.matlab, source.m':
    """
    for (fun, val) in data
        try
        if haskey(val, "inputs")
            argsIn = val["inputs"]

            argsIn = mutuallyExclusiveGroup_handler(argsIn)

            numIn = length(argsIn)
            if numIn > 0
                in = Vector{String}(undef, numIn)
                inDesc = Vector{String}(undef, numIn)
                for (iIn, arg) in enumerate(argsIn)

                    # mutuallyExclusiveGroup handler
                    # replaces that with the first option for the snippet
                    if haskey(arg, "mutuallyExclusiveGroup")
                        options = arg["mutuallyExclusiveGroup"]
                        if options[1] isa Vector
                            arg = options[1]
                        else
                            arg = [options[1]]
                        end
                        if length(arg) == 0
                            Base.deleteat!(in, iIn)
                            continue
                        end
                    end

                    kind = arg["kind"]
                    if kind == "varargin"
                        name = "varargin"
                    elseif haskey(arg,"name")
                        name = arg["name"]
                    else
                        name = "arg"
                    end

                    if kind == "namevalue"
                        in[iIn]="\'$name\', \${$iIn:value}"
                        inDesc[iIn] = "\'$name\', value"
                    elseif kind == "ordered"
                        in[iIn]="\${$iIn:optional_$name}"
                        inDesc[iIn] = "optional_$name"
                    else
                        in[iIn]="\${$iIn:$name}"
                        inDesc[iIn] = "$name"
                    end
                end
                argsInStr = join(in, ", ")
                strIn = "$fun($argsInStr)"

                argsInStrDesc = join(inDesc, ", ")
                strInDesc = "$fun($argsInStrDesc)"
            else
                strIn = "$fun()"
                strInDesc = "$fun()"
            end
        end

        if haskey(val, "outputs")
            argsOut = val["outputs"]
            numOut = length(argsOut)
            out = Vector{String}(undef, numOut)
            outDesc = Vector{String}(undef, numOut)

            for (iOut, arg) in enumerate(argsOut)
                out[iOut]="\${$iOut:$(arg["name"])}"

                outDesc[iOut]="$(arg["name"])"
            end
            if numOut > 1
                argsOutStr = join(out, ", ")
                strOut = "[$argsOutStr]"
                body = "$strOut = $strIn"

                argsOutStrDesc = join(outDesc, ", ")
                strOutDesc = "[$argsOutStrDesc]"
                description = "$strOutDesc = $strInDesc"

            elseif numOut == 1
                strOut = "$(out[1])"
                body = "$strOut = $strIn"

                strOutDesc = "$(outDesc[1])"
                description = "$strOutDesc = $strInDesc"

            else
                body = "$strIn"
                description = "$strInDesc"

            end

        else
            body = "$strIn"
            description = "$strInDesc"
        end


        final *= """

            "$fun":
                prefix: "$fun"
                body: '''$body'''
                description: '''$description'''

        """
        catch
            println("arguments not supported yet")
        end
    end

    return final
end


function run_matlab2atom()

    files = ["toolbox/vision/vision/resources/functionSignatures.json",
    "toolbox/targetdefinition/targetsdk/targetpackage/resources/functionSignatures.json",
    "toolbox/target/codertarget/resources/functionSignatures.json",
    "toolbox/target/codertarget/matlabcoder/resources/functionSignatures.json",
    "toolbox/symbolic/symbolic/resources/functionSignatures.json",
    "toolbox/symbolic/graphics/resources/functionSignatures.json",
    "toolbox/stats/stats/resources/functionSignatures.json",
    "toolbox/stats/featlearn/resources/functionSignatures.json",
    "toolbox/stats/clustering/resources/functionSignatures.json",
    "toolbox/stats/classreg/resources/functionSignatures.json",
    "toolbox/stats/bigdata/resources/functionSignatures.json",
    "toolbox/stats/bayesoptim/resources/functionSignatures.json",
    "toolbox/simulink/slexportprevious/resources/functionSignatures.json",
    "toolbox/simulink/simulink/slproject/resources/functionSignatures.json",
    "toolbox/simulink/simulink/resources/functionSignatures.json",
    "toolbox/simulink/simulationinput/resources/functionSignatures.json",
    "toolbox/simulink/batchsim/resources/functionSignatures.json",
    "toolbox/signal/sigtools/resources/functionSignatures.json",
    "toolbox/signal/signal/resources/functionSignatures.json",
    "toolbox/shared/testmeaslib/general/resources/functionSignatures.json",
    "toolbox/shared/statslib/resources/functionSignatures.json",
    "toolbox/shared/spreadsheet/resources/functionSignatures.json",
    "toolbox/shared/signalwavelet/signalwavelet/resources/functionSignatures.json",
    "toolbox/shared/siglib/resources/functionSignatures.json",
    "toolbox/shared/pointclouds/resources/functionSignatures.json",
    "toolbox/shared/optimlib/resources/functionSignatures.json",
    "toolbox/shared/mlreportgen/utils/resources/functionSignatures.json",
    "toolbox/shared/mlearnlib/resources/functionSignatures.json",
    "toolbox/shared/measure/resources/functionSignatures.json",
    "toolbox/shared/io/resources/functionSignatures.json",
    "toolbox/shared/instrument/resources/functionSignatures.json",
    "toolbox/shared/imageio/resources/functionSignatures.json",
    "toolbox/shared/geodesy/resources/functionSignatures.json",
    "toolbox/shared/dsp/vision/matlab/vision/resources/functionSignatures.json",
    "toolbox/shared/dsp/hdl/resources/functionSignatures.json",
    "toolbox/shared/dastudio/dpvu/dpvu/resources/functionSignatures.json",
    "toolbox/shared/comparisons/resources/functionSignatures.json",
    "toolbox/shared/comm_msblks_serdes/resources/functionSignatures.json",
    "toolbox/shared/channel/rfprop/resources/functionSignatures.json",
    "toolbox/shared/can/resources/functionSignatures.json",
    "toolbox/shared/blelib/resources/functionSignatures.json",
    "toolbox/shared/basemaps/resources/functionSignatures.json",
    "toolbox/rtw/rtw/resources/functionSignatures.json",
    "toolbox/physmod/simscape/templates/resources/functionSignatures.json",
    "toolbox/physmod/common/dataservices/mli/m/resources/functionSignatures.json",
    "toolbox/pde/resources/functionSignatures.json",
    "toolbox/parallel/resources/functionSignatures.json",
    "toolbox/parallel/mpi/resources/functionSignatures.json",
    "toolbox/parallel/cluster/resources/functionSignatures.json",
    "toolbox/optim/problemdef/resources/functionSignatures.json",
    "toolbox/nnet/deepviz/resources/functionSignatures.json",
    "toolbox/nnet/deep/resources/functionSignatures.json",
    "toolbox/nnet/cnn/spkgs/resources/functionSignatures.json",
    "toolbox/nnet/cnn/resources/functionSignatures.json",
    "toolbox/matlab/winfun/resources/functionSignatures.json",
    "toolbox/matlab/uitools/uicomponents/components/resources/functionSignatures.json",
    "toolbox/matlab/uitools/resources/functionSignatures.json",
    "toolbox/matlab/uicomponents/uicomponents/style/resources/functionSignatures.json",
    "toolbox/matlab/uicomponents/uicomponents/resources/functionSignatures.json",
    "toolbox/matlab/uicomponents/uicomponents/graphics/resources/functionSignatures.json",
    "toolbox/matlab/timefun/resources/functionSignatures.json",
    "toolbox/matlab/testframework/unittest/ext/resources/functionSignatures.json",
    "toolbox/matlab/testframework/unittest/core/resources/functionSignatures.json",
    "toolbox/matlab/testframework/performance/core/resources/functionSignatures.json",
    "toolbox/matlab/system/resources/functionSignatures.json",
    "toolbox/matlab/strfun/resources/functionSignatures.json",
    "toolbox/matlab/specgraph/resources/functionSignatures.json",
    "toolbox/matlab/sparfun/resources/functionSignatures.json",
    "toolbox/matlab/serialport/resources/functionSignatures.json",
    "toolbox/matlab/serial/resources/functionSignatures.json",
    "toolbox/matlab/scribe/resources/functionSignatures.json",
    "toolbox/matlab/randfun/resources/functionSignatures.json",
    "toolbox/matlab/project/resources/functionSignatures.json",
    "toolbox/matlab/polyfun/resources/functionSignatures.json",
    "toolbox/matlab/parquetio/resources/functionSignatures.json",
    "toolbox/matlab/parquetds/resources/functionSignatures.json",
    "toolbox/matlab/ops/resources/functionSignatures.json",
    "toolbox/matlab/networklib/resources/functionSignatures.json",
    "toolbox/matlab/matfun/resources/functionSignatures.json",
    "toolbox/matlab/mapreduceio/resources/functionSignatures.json",
    "toolbox/matlab/lang/resources/functionSignatures.json",
    "toolbox/matlab/iot/connectivity/resources/functionSignatures.json",
    "toolbox/matlab/iofun/resources/functionSignatures.json",
    "toolbox/matlab/imagesci/resources/functionSignatures.json",
    "toolbox/matlab/images/resources/functionSignatures.json",
    "toolbox/matlab/helptools/resources/functionSignatures.json",
    "toolbox/matlab/guide/resources/functionSignatures.json",
    "toolbox/matlab/graphics/resources/functionSignatures.json",
    "toolbox/matlab/graphics/primitive/resources/functionSignatures.json",
    "toolbox/matlab/graphics/objectsystem/resources/functionSignatures.json",
    "toolbox/matlab/graphics/maps/resources/functionSignatures.json",
    "toolbox/matlab/graphics/function/resources/functionSignatures.json",
    "toolbox/matlab/graphics/axis/resources/functionSignatures.json",
    "toolbox/matlab/graphfun/resources/functionSignatures.json",
    "toolbox/matlab/graph3d/resources/functionSignatures.json",
    "toolbox/matlab/graph2d/resources/functionSignatures.json",
    "toolbox/matlab/general/resources/functionSignatures.json",
    "toolbox/matlab/funfun/resources/functionSignatures.json",
    "toolbox/matlab/external/interfaces/webservices/restful/resources/functionSignatures.json",
    "toolbox/matlab/external/interfaces/webservices/http/resources/functionSignatures.json",
    "toolbox/matlab/external/interfaces/python/resources/functionSignatures.json",
    "toolbox/matlab/external/interfaces/cpp/resources/functionSignatures.json",
    "toolbox/matlab/elmat/resources/functionSignatures.json",
    "toolbox/matlab/elfun/resources/functionSignatures.json",
    # "toolbox/matlab/dataui/resources/functionSignatures.json",
    "toolbox/matlab/datatypes/resources/functionSignatures.json",
    "toolbox/matlab/datatypes/categorical/resources/functionSignatures.json",
    "toolbox/matlab/datatypes/calendarDuration/resources/functionSignatures.json",
    "toolbox/matlab/datastoreio/resources/functionSignatures.json",
    "toolbox/matlab/datafun/resources/functionSignatures.json",
    "toolbox/matlab/connector2/shadowfiles/shadows/help/resources/functionSignatures.json",
    "toolbox/matlab/connector2/shadowfiles/shadows/edit+jsd/resources/functionSignatures.json",
    "toolbox/matlab/connector2/shadowfiles/shadows/doc+cloud/resources/functionSignatures.json",
    "toolbox/matlab/codetools/resources/functionSignatures.json",
    "toolbox/matlab/codeanalysis/analysis/resources/functionSignatures.json",
    "toolbox/matlab/bigdata/resources/functionSignatures.json",
    "toolbox/matlab/audiovideo/resources/functionSignatures.json",
    "toolbox/matlab/appdesigner/appdesigner/resources/functionSignatures.json",
    "toolbox/matlab/addon_enable_disable_management/matlab/resources/functionSignatures.json",
    "toolbox/map/mapproj/resources/functionSignatures.json",
    "toolbox/map/mapgeodesy/resources/functionSignatures.json",
    "toolbox/map/mapformats/resources/functionSignatures.json",
    "toolbox/map/mapdisp/resources/functionSignatures.json",
    "toolbox/map/map/resources/functionSignatures.json",
    "toolbox/local/resources/functionSignatures.json",
    "toolbox/instrument/instrument/resources/functionSignatures.json",
    "toolbox/imaq/imaqblks/imaqmasks/resources/functionSignatures.json",
    "toolbox/imaq/imaq/resources/functionSignatures.json",
    "toolbox/images/iptformats/resources/functionSignatures.json",
    "toolbox/images/imuitools/resources/functionSignatures.json",
    "toolbox/images/images/resources/functionSignatures.json",
    "toolbox/images/deep/resources/functionSignatures.json",
    "toolbox/images/colorspaces/resources/functionSignatures.json",
    # "toolbox/ident/idguis/resources/functionSignatures.json",
    "toolbox/globaloptim/globaloptim/resources/functionSignatures.json",
    "toolbox/geoweb/geoweb/resources/functionSignatures.json",
    "toolbox/fixpoint/resources/functionSignatures.json",
    "toolbox/fixedpoint/fixedpoint/resources/functionSignatures.json",
    "toolbox/finance/finsupport/resources/functionSignatures.json",
    "toolbox/finance/finance/resources/functionSignatures.json",
    "toolbox/finance/calendar/resources/functionSignatures.json",
    "toolbox/dsp/filterdesign/resources/functionSignatures.json",
    "toolbox/dsp/dsp/resources/functionSignatures.json",
    "toolbox/dsp/dsp/compiled/resources/functionSignatures.json",
    "toolbox/daq/daq/resources/functionSignatures.json",
    # "toolbox/control/ctrlguis/resources/functionSignatures.json",
    "toolbox/compiler/resources/functionSignatures.json",
    "toolbox/compiler/java/resources/functionSignatures.json",
    "toolbox/comm/comm/resources/functionSignatures.json",
    "toolbox/comm/comm/compiled/resources/functionSignatures.json",
    "toolbox/coder/xrel/resources/functionSignatures.json",
    "toolbox/coder/xcp/resources/functionSignatures.json",
    "toolbox/coder/simulinkcoder/resources/functionSignatures.json",
    "toolbox/coder/matlabcoder/resources/functionSignatures.json",
    "toolbox/coder/embeddedcoder/resources/functionSignatures.json",
    "toolbox/coder/connectivity/resources/functionSignatures.json",
    "toolbox/coder/coder/resources/functionSignatures.json",
    "toolbox/aero/uicomponents/resources/functionSignatures.json",
    ]

    println("conversion started")
    for file in files
        data = JSON.parsefile(file; dicttype=Dict, inttype=Int64, use_mmap=true)
        text = matlab2atom(data)

        # rename file
        file = foldl(replace,
                     (
                      "toolbox/"=>"",
                      "resources/"=>"",
                      "functionSignatures"=>"",
                      "/"=>"_",
                     ),
                     init = file)
        file = "snippets/"*file[1:end-4]*"cson"

        Base.write(file,text)
    end
    println("conversion finsished successfully")

end

run_matlab2atom()
