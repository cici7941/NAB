###################################################
#
# Copyright © Akamai Technologies. All rights reserved.
# Proprietary and confidential.
#
# File: runtests.jl
#
# This document aims to test functions from the NAB module.
#
###################################################

const __currentdir = dirname(@__FILE__)

include(joinpath(dirname(@__FILE__), "scorer_test.jl"))
include(joinpath(dirname(@__FILE__), "true_positive_test.jl"))