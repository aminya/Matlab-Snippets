using AcuteML

# Types definition

# helps
@aml mutable struct Fun "tocitem"
    name::UN{String} = nothing, "~"
    purpose::UN{String} = nothing, "~"
    docurl::UN{String} = nothing, a"target"
end

@aml mutable struct Group "tocitem"
    funs::Vector{Fun}, "tocitem"
    # groupname::String, t""
    docurlroot::String, a"target"
end

@aml mutable struct Help "tocitem"
    groups::Vector{Group}, "tocitem"
    # helpname::String, t""
    filename::String, a"target"
end

@aml mutable struct toc "~"
    help::Help, "tocitem"
    version::String, a"~"
end

@aml mutable struct Doc "xml"
    toc::toc, "~"
end

function description_parse()
    xmlfiles = ["input/help/wavelet/helpfuncbycat.xml",
    "input/help/vision/helpfuncbycat.xml",
    "input/help/symbolic/helpfuncbycat.xml",
    "input/help/stats/helpfuncbycat.xml",
    "input/help/stateflow/helpfuncbycat.xml",
    "input/help/slcontrol/helpfuncbycat.xml",
    "input/help/sl3d/helpfuncbycat.xml",
    "input/help/simulink/helpfuncbycat.xml",
    "input/help/signal/helpfuncbycat.xml",
    "input/help/rtw/helpfuncbycat.xml",
    "input/help/robust/helpfuncbycat.xml",
    "input/help/relnotes/helpfuncbycat.xml",
    "input/help/physmod/sps/helpfuncbycat.xml",
    "input/help/physmod/sm/helpfuncbycat.xml",
    "input/help/physmod/simscape/helpfuncbycat.xml",
    "input/help/pde/helpfuncbycat.xml",
    "input/help/parallel-computing/helpfuncbycat.xml",
    "input/help/optim/helpfuncbycat.xml",
    "input/help/mpc/helpfuncbycat.xml",
    "input/help/matlab/helpfuncbycat.xml",
    "input/help/map/helpfuncbycat.xml",
    "input/help/instrument/helpfuncbycat.xml",
    "input/help/imaq/helpfuncbycat.xml",
    "input/help/images/helpfuncbycat.xml",
    "input/help/ident/helpfuncbycat.xml",
    "input/help/gads/helpfuncbycat.xml",
    "input/help/fuzzy/helpfuncbycat.xml",
    "input/help/finance/helpfuncbycat.xml",
    "input/help/econ/helpfuncbycat.xml",
    "input/help/ecoder/helpfuncbycat.xml",
    "input/help/dsp/helpfuncbycat.xml",
    "input/help/deeplearning/helpfuncbycat.xml",
    "input/help/daq/helpfuncbycat.xml",
    "input/help/curvefit/helpfuncbycat.xml",
    "input/help/control/helpfuncbycat.xml",
    "input/help/compiler_sdk/helpfuncbycat.xml",
    "input/help/compiler/helpfuncbycat.xml",
    "input/help/comm/helpfuncbycat.xml",
    "input/help/coder/helpfuncbycat.xml",
    "input/help/bioinfo/helpfuncbycat.xml",
    "input/help/aerotbx/helpfuncbycat.xml",
    "input/help/aeroblks/helpfuncbycat.xml",
    ]

    numfile = length(xmlfiles)
    docs = Vector{Doc}(undef, numfile)
    groups = Vector{String}(undef, numfile)

    for (i, file) in enumerate(xmlfiles)
        groups[i] = match(r"input\/help\/(.+)\/", file).captures[1]
        xml = readxml(file)
        docs[i] = Doc(xml)
    end
    dict = Dict(g => d for (d, g) in zip(docs, groups))
    return dict
end

description_dict = description_parse()
