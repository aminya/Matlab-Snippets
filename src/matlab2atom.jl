# using Pkg; Pkg.add("JSON"); Pkg.add("AcuteML"); Pkg.add("StructArrays");
using JSON, StructArrays

include("function_description.jl")

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

function matlab2atom(data, group)
    final = """
    # MATLAB snippets generated using https://github.com/aminya/Matlab-Snippets
    '.source.matlab, source.m':
    """
    try
        funs = reduce(vcat, StructArray(description_dict[group].toc.help.groups).funs)
        fundict = Dict(f.name => f for f in funs)
    catch

    end

    for (fun, val) in data
        try
        if haskey(val, "inputs")
            argsIn = val["inputs"]

            argsIn = mutuallyExclusiveGroup_handler(argsIn)

            numIn = length(argsIn)
            if numIn > 0
                in = Vector{String}(undef, numIn)
                inProto = Vector{String}(undef, numIn)
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
                        inProto[iIn] = "\'$name\', value"
                    elseif kind == "ordered"
                        in[iIn]="\${$iIn:optional_$name}"
                        inProto[iIn] = "optional_$name"
                    else
                        in[iIn]="\${$iIn:$name}"
                        inProto[iIn] = "$name"
                    end
                end
                argsInStr = join(in, ", ")
                strIn = "$fun($argsInStr)"

                argsInStrProto = join(inProto, ", ")
                strInProto = "$fun($argsInStrProto)"
            else
                strIn = "$fun()"
                strInProto = "$fun()"
            end
        end

        if haskey(val, "outputs")
            argsOut = val["outputs"]
            numOut = length(argsOut)
            out = Vector{String}(undef, numOut)
            outProto = Vector{String}(undef, numOut)

            for (iOut, arg) in enumerate(argsOut)
                out[iOut]="\${$iOut:$(arg["name"])}"

                outProto[iOut]="$(arg["name"])"
            end
            if numOut > 1
                argsOutStr = join(out, ", ")
                strOut = "[$argsOutStr]"
                body = "$strOut = $strIn"

                argsOutStrProto = join(outProto, ", ")
                strOutProto = "[$argsOutStrProto]"
                prototype = "$strOutProto = $strInProto"

            elseif numOut == 1
                strOut = "$(out[1])"
                body = "$strOut = $strIn"

                strOutProto = "$(outProto[1])"
                prototype = "$strOutProto = $strInProto"

            else
                body = "$strIn"
                prototype = "$strInProto"

            end

        else
            body = "$strIn"
            prototype = "$strInProto"
        end


        try
            purpose = fundict[fun].purpose
            descriptionMoreURL = "https://www.mathworks.com/help/$group/"*fundict[fun].docurl
        catch
            purpose = ""
            if group == "matlab"
                descriptionMoreURL = "https://www.mathworks.com/help/$group/ref/$fun.html"
            else
                descriptionMoreURL = "https://www.mathworks.com/help/$group/$fun.html"
            end
        end


        final *= """

            "$fun [$group]":
                prefix: "$fun"
                body: '''$body'''
                description: '''[$group] $purpose
                $prototype
                '''
                descriptionMoreURL: '$descriptionMoreURL'

        """
        catch
            println("arguments not supported yet")
        end
    end

    return final
end


function run_matlab2atom()

    jsonfiles = ["input/toolbox/vision/vision/resources/functionSignatures.json",
    "input/toolbox/targetdefinition/targetsdk/targetpackage/resources/functionSignatures.json",
    "input/toolbox/target/codertarget/resources/functionSignatures.json",
    "input/toolbox/target/codertarget/matlabcoder/resources/functionSignatures.json",
    "input/toolbox/symbolic/symbolic/resources/functionSignatures.json",
    "input/toolbox/symbolic/graphics/resources/functionSignatures.json",
    "input/toolbox/stats/stats/resources/functionSignatures.json",
    "input/toolbox/stats/featlearn/resources/functionSignatures.json",
    "input/toolbox/stats/clustering/resources/functionSignatures.json",
    "input/toolbox/stats/classreg/resources/functionSignatures.json",
    "input/toolbox/stats/bigdata/resources/functionSignatures.json",
    "input/toolbox/stats/bayesoptim/resources/functionSignatures.json",
    "input/toolbox/simulink/slexportprevious/resources/functionSignatures.json",
    "input/toolbox/simulink/simulink/slproject/resources/functionSignatures.json",
    "input/toolbox/simulink/simulink/resources/functionSignatures.json",
    "input/toolbox/simulink/simulationinput/resources/functionSignatures.json",
    "input/toolbox/simulink/batchsim/resources/functionSignatures.json",
    "input/toolbox/signal/sigtools/resources/functionSignatures.json",
    "input/toolbox/signal/signal/resources/functionSignatures.json",
    "input/toolbox/shared/testmeaslib/general/resources/functionSignatures.json",
    "input/toolbox/shared/statslib/resources/functionSignatures.json",
    "input/toolbox/shared/spreadsheet/resources/functionSignatures.json",
    "input/toolbox/shared/signalwavelet/signalwavelet/resources/functionSignatures.json",
    "input/toolbox/shared/siglib/resources/functionSignatures.json",
    "input/toolbox/shared/pointclouds/resources/functionSignatures.json",
    "input/toolbox/shared/optimlib/resources/functionSignatures.json",
    "input/toolbox/shared/mlreportgen/utils/resources/functionSignatures.json",
    "input/toolbox/shared/mlearnlib/resources/functionSignatures.json",
    "input/toolbox/shared/measure/resources/functionSignatures.json",
    "input/toolbox/shared/io/resources/functionSignatures.json",
    "input/toolbox/shared/instrument/resources/functionSignatures.json",
    "input/toolbox/shared/imageio/resources/functionSignatures.json",
    "input/toolbox/shared/geodesy/resources/functionSignatures.json",
    "input/toolbox/shared/dsp/vision/matlab/vision/resources/functionSignatures.json",
    "input/toolbox/shared/dsp/hdl/resources/functionSignatures.json",
    "input/toolbox/shared/dastudio/dpvu/dpvu/resources/functionSignatures.json",
    "input/toolbox/shared/comparisons/resources/functionSignatures.json",
    "input/toolbox/shared/comm_msblks_serdes/resources/functionSignatures.json",
    "input/toolbox/shared/channel/rfprop/resources/functionSignatures.json",
    "input/toolbox/shared/can/resources/functionSignatures.json",
    "input/toolbox/shared/blelib/resources/functionSignatures.json",
    "input/toolbox/shared/basemaps/resources/functionSignatures.json",
    "input/toolbox/rtw/rtw/resources/functionSignatures.json",
    "input/toolbox/physmod/simscape/templates/resources/functionSignatures.json",
    "input/toolbox/physmod/common/dataservices/mli/m/resources/functionSignatures.json",
    "input/toolbox/pde/resources/functionSignatures.json",
    "input/toolbox/parallel/resources/functionSignatures.json",
    "input/toolbox/parallel/mpi/resources/functionSignatures.json",
    "input/toolbox/parallel/cluster/resources/functionSignatures.json",
    "input/toolbox/optim/problemdef/resources/functionSignatures.json",
    "input/toolbox/nnet/deepviz/resources/functionSignatures.json",
    "input/toolbox/nnet/deep/resources/functionSignatures.json",
    "input/toolbox/nnet/cnn/spkgs/resources/functionSignatures.json",
    "input/toolbox/nnet/cnn/resources/functionSignatures.json",
    "input/toolbox/matlab/winfun/resources/functionSignatures.json",
    "input/toolbox/matlab/uitools/uicomponents/components/resources/functionSignatures.json",
    "input/toolbox/matlab/uitools/resources/functionSignatures.json",
    "input/toolbox/matlab/uicomponents/uicomponents/style/resources/functionSignatures.json",
    "input/toolbox/matlab/uicomponents/uicomponents/resources/functionSignatures.json",
    "input/toolbox/matlab/uicomponents/uicomponents/graphics/resources/functionSignatures.json",
    "input/toolbox/matlab/timefun/resources/functionSignatures.json",
    "input/toolbox/matlab/testframework/unittest/ext/resources/functionSignatures.json",
    "input/toolbox/matlab/testframework/unittest/core/resources/functionSignatures.json",
    "input/toolbox/matlab/testframework/performance/core/resources/functionSignatures.json",
    "input/toolbox/matlab/system/resources/functionSignatures.json",
    "input/toolbox/matlab/strfun/resources/functionSignatures.json",
    "input/toolbox/matlab/specgraph/resources/functionSignatures.json",
    "input/toolbox/matlab/sparfun/resources/functionSignatures.json",
    "input/toolbox/matlab/serialport/resources/functionSignatures.json",
    "input/toolbox/matlab/serial/resources/functionSignatures.json",
    "input/toolbox/matlab/scribe/resources/functionSignatures.json",
    "input/toolbox/matlab/randfun/resources/functionSignatures.json",
    "input/toolbox/matlab/project/resources/functionSignatures.json",
    "input/toolbox/matlab/polyfun/resources/functionSignatures.json",
    "input/toolbox/matlab/parquetio/resources/functionSignatures.json",
    "input/toolbox/matlab/parquetds/resources/functionSignatures.json",
    "input/toolbox/matlab/ops/resources/functionSignatures.json",
    "input/toolbox/matlab/networklib/resources/functionSignatures.json",
    "input/toolbox/matlab/matfun/resources/functionSignatures.json",
    "input/toolbox/matlab/mapreduceio/resources/functionSignatures.json",
    "input/toolbox/matlab/lang/resources/functionSignatures.json",
    "input/toolbox/matlab/iot/connectivity/resources/functionSignatures.json",
    "input/toolbox/matlab/iofun/resources/functionSignatures.json",
    "input/toolbox/matlab/imagesci/resources/functionSignatures.json",
    "input/toolbox/matlab/images/resources/functionSignatures.json",
    "input/toolbox/matlab/helptools/resources/functionSignatures.json",
    "input/toolbox/matlab/guide/resources/functionSignatures.json",
    "input/toolbox/matlab/graphics/resources/functionSignatures.json",
    "input/toolbox/matlab/graphics/primitive/resources/functionSignatures.json",
    "input/toolbox/matlab/graphics/objectsystem/resources/functionSignatures.json",
    "input/toolbox/matlab/graphics/maps/resources/functionSignatures.json",
    "input/toolbox/matlab/graphics/function/resources/functionSignatures.json",
    "input/toolbox/matlab/graphics/axis/resources/functionSignatures.json",
    "input/toolbox/matlab/graphfun/resources/functionSignatures.json",
    "input/toolbox/matlab/graph3d/resources/functionSignatures.json",
    "input/toolbox/matlab/graph2d/resources/functionSignatures.json",
    "input/toolbox/matlab/general/resources/functionSignatures.json",
    "input/toolbox/matlab/funfun/resources/functionSignatures.json",
    "input/toolbox/matlab/external/interfaces/webservices/restful/resources/functionSignatures.json",
    "input/toolbox/matlab/external/interfaces/webservices/http/resources/functionSignatures.json",
    "input/toolbox/matlab/external/interfaces/python/resources/functionSignatures.json",
    "input/toolbox/matlab/external/interfaces/cpp/resources/functionSignatures.json",
    "input/toolbox/matlab/elmat/resources/functionSignatures.json",
    "input/toolbox/matlab/elfun/resources/functionSignatures.json",
    # "input/toolbox/matlab/dataui/resources/functionSignatures.json",
    "input/toolbox/matlab/datatypes/resources/functionSignatures.json",
    "input/toolbox/matlab/datatypes/categorical/resources/functionSignatures.json",
    "input/toolbox/matlab/datatypes/calendarDuration/resources/functionSignatures.json",
    "input/toolbox/matlab/datastoreio/resources/functionSignatures.json",
    "input/toolbox/matlab/datafun/resources/functionSignatures.json",
    "input/toolbox/matlab/connector2/shadowfiles/shadows/help/resources/functionSignatures.json",
    "input/toolbox/matlab/connector2/shadowfiles/shadows/edit+jsd/resources/functionSignatures.json",
    "input/toolbox/matlab/connector2/shadowfiles/shadows/doc+cloud/resources/functionSignatures.json",
    "input/toolbox/matlab/codetools/resources/functionSignatures.json",
    "input/toolbox/matlab/codeanalysis/analysis/resources/functionSignatures.json",
    "input/toolbox/matlab/bigdata/resources/functionSignatures.json",
    "input/toolbox/matlab/audiovideo/resources/functionSignatures.json",
    "input/toolbox/matlab/appdesigner/appdesigner/resources/functionSignatures.json",
    "input/toolbox/matlab/addon_enable_disable_management/matlab/resources/functionSignatures.json",
    "input/toolbox/map/mapproj/resources/functionSignatures.json",
    "input/toolbox/map/mapgeodesy/resources/functionSignatures.json",
    "input/toolbox/map/mapformats/resources/functionSignatures.json",
    "input/toolbox/map/mapdisp/resources/functionSignatures.json",
    "input/toolbox/map/map/resources/functionSignatures.json",
    "input/toolbox/local/resources/functionSignatures.json",
    "input/toolbox/instrument/instrument/resources/functionSignatures.json",
    "input/toolbox/imaq/imaqblks/imaqmasks/resources/functionSignatures.json",
    "input/toolbox/imaq/imaq/resources/functionSignatures.json",
    "input/toolbox/images/iptformats/resources/functionSignatures.json",
    "input/toolbox/images/imuitools/resources/functionSignatures.json",
    "input/toolbox/images/images/resources/functionSignatures.json",
    "input/toolbox/images/deep/resources/functionSignatures.json",
    "input/toolbox/images/colorspaces/resources/functionSignatures.json",
    # "input/toolbox/ident/idguis/resources/functionSignatures.json",
    "input/toolbox/globaloptim/globaloptim/resources/functionSignatures.json",
    "input/toolbox/geoweb/geoweb/resources/functionSignatures.json",
    "input/toolbox/fixpoint/resources/functionSignatures.json",
    "input/toolbox/fixedpoint/fixedpoint/resources/functionSignatures.json",
    "input/toolbox/finance/finsupport/resources/functionSignatures.json",
    "input/toolbox/finance/finance/resources/functionSignatures.json",
    "input/toolbox/finance/calendar/resources/functionSignatures.json",
    "input/toolbox/dsp/filterdesign/resources/functionSignatures.json",
    "input/toolbox/dsp/dsp/resources/functionSignatures.json",
    "input/toolbox/dsp/dsp/compiled/resources/functionSignatures.json",
    "input/toolbox/daq/daq/resources/functionSignatures.json",
    # "input/toolbox/control/ctrlguis/resources/functionSignatures.json",
    "input/toolbox/compiler/resources/functionSignatures.json",
    "input/toolbox/compiler/java/resources/functionSignatures.json",
    "input/toolbox/comm/comm/resources/functionSignatures.json",
    "input/toolbox/comm/comm/compiled/resources/functionSignatures.json",
    "input/toolbox/coder/xrel/resources/functionSignatures.json",
    "input/toolbox/coder/xcp/resources/functionSignatures.json",
    "input/toolbox/coder/simulinkcoder/resources/functionSignatures.json",
    "input/toolbox/coder/matlabcoder/resources/functionSignatures.json",
    "input/toolbox/coder/embeddedcoder/resources/functionSignatures.json",
    "input/toolbox/coder/connectivity/resources/functionSignatures.json",
    "input/toolbox/coder/coder/resources/functionSignatures.json",
    "input/toolbox/aero/uicomponents/resources/functionSignatures.json",
    ]

    println("conversion started")
    for file in jsonfiles
        group = match(r"toolbox\/([a-z]+)\/", file).captures[1]
        data = JSON.parsefile(file; dicttype=Dict, inttype=Int64, use_mmap=true)
        text = matlab2atom(data, group)

        # rename file
        file = foldl(replace,
                     (
                      "input/toolbox/"=>"",
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
