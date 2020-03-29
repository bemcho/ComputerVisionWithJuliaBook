module ComputerVisionWithJuliaBook
using Pkg
Pkg.activate(normpath(joinpath(@__DIR__, "..")))

include("CVUI.jl")

function julia_main()::Cint
    # do something based on ARGS?
    CVUI.initUI()
    return 0 # if things finished successfully
end
#comment when building native app
#julia_main()
end
