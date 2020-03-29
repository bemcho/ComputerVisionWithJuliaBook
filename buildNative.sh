#!/usr/bin/bash
cd ..
echo "Do not forget to comment call to julia_main() ComputerVisionWithJuliaBook.jl"
julia --startup-file=no  -q --project -e 'using PackageCompiler;create_app("ComputerVisionWithJuliaBook", "ComputerVisionWithJuliaBook/native",incremental=false,force=true)'


