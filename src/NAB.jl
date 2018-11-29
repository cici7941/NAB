###################################################
#
# Copyright © Akamai Technologies. All rights reserved.
# Proprietary and confidential.
#
# File: NAB.jl
#
# Contains Numenta Anomaly Benchmark Computation
#
###################################################

__precompile__(true)

module NAB

using Compat, Base.Dates
using DataFrames, DataArrays, JSON, Logging

# This should bind at compile time, so @__FILE__ is set to NAB.jl
const __module_dir = dirname(dirname(@__FILE__))

if !isdefined(:readstring)
    readstring(x) = readall(x)
end

include(joinpath(__module_dir, "src", "labeler.jl"))
include(joinpath(__module_dir, "src", "util.jl"))
include(joinpath(__module_dir, "src", "scorer.jl"))


"""
$(readstring(joinpath(NAB.__module_dir, "README.md")))

### Exports:

$(join(map(x -> "* [$x](@ref)", names(NAB)[2:end]), "\n"))
"""
NAB

end