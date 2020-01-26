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

        local purpose, descriptionMoreURL

        try
            purpose = funsdict[fun].purpose
            descriptionMoreURL = "https://www.mathworks.com/help/$group/"*funsdict[fun].docurl
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
        catch e
            println("arguments not supported yet")
        end
    end

    return final
end


function run_matlab2atom()

    include("fileslist/jsonfileslist.jl")

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
