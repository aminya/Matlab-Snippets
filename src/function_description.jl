using AcuteML, StructArrays, EzXML

# Types definition

# helps
@aml mutable struct Fun "tocitem"
    name::String, "~"
    purpose::String, "~"
    docurl::String, a"target"
end

function recursive_search!(in)
    for elm in eachelement(in)
        if haselement(elm)
            elm_name = firstelement(elm).name
            if elm_name == "name"
                push!(allnodes, elm)
            else
                recursive_search!(elm)
            end
        end
    end
end

function description_parse()
    global allnodes
    allnodes = Node[]
    include("fileslist/xmlfileslist.jl")

    numfile = length(xmlfiles)
    groups = Vector{String}(undef, numfile)
    funs = Vector{Vector{Fun}}(undef, numfile)

    for (i, file) in enumerate(xmlfiles)
        groups[i] = match(r"input\/help\/(.+)\/", file).captures[1]
        xml = readxml(file)
        recursive_search!(root(xml))
        funs[i] = Fun.(allnodes)
    end
    allfuns = reduce(vcat, funs)

    dict = Dict(f.name => f for f in allfuns)

    return dict
end

funsdict = description_parse()
