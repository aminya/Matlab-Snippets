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

    include("fileslist/xmlfileslist.jl")
    xmlfiles = xmlfiles[20:21]

    numfile = length(xmlfiles)
    docs = Vector{Any}(undef, numfile)
    groups = Vector{String}(undef, numfile)
    types = Vector{Integer}(undef, numfile)

    for (i, file) in enumerate(xmlfiles)
        groups[i] = match(r"input\/help\/(.+)\/", file).captures[1]
        xml = readxml(file)
        try
            # @infiltrate
            docs[i] = Doc2(xml)
            types[i] = 2
        catch
            docs[i] = Doc(xml)
            types[i] = 1
        end

    end
    dict = Dict(g => d for (d, g) in zip(docs, groups))

    funs_docs = Vector{Fun}(undef, numfile)
    for (d, t) in zip(docs, types)
        if t == 1
            funs_docs[i] = reduce(vcat,
                                StructArray(
                                        reduce(vcat,
                                            StructArray(
                                                StructArray(
                                                    d.toc
                                                ).help
                                            ).groups
                                        )
                                ).funs,
                            )
        else t == 2
            funs_docs[i] = StructArray(
                                reduce(vcat,
                                    StructArray(
                                            reduce(vcat,
                                                StructArray(
                                                    StructArray(
                                                        d.toc
                                                    ).help
                                                ).groups
                                            )
                                    ).subgroup
                                )
                            ).funs
        end
    end

    return dict, docs, funs_docs
end

# description_dict, docs, funs_docs = description_parse()

function description_parse2()
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

funsdict = description_parse2()
