using Documenter, ComputerVisionWithJuliaBook

makedocs(modules = [ComputerVisionWithJuliaBook], sitename = "ComputerVisionWithJuliaBook.jl")

deploydocs(repo = "github.com/bemcho/ComputerVisionWithJuliaBook.git")
