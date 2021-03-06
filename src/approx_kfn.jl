export approx_kfn

using mlpack.util.cli

import mlpack_jll
const approx_kfnLibrary = mlpack_jll.libmlpack_julia_approx_kfn

# Call the C binding of the mlpack approx_kfn binding.
function approx_kfn_mlpackMain()
  success = ccall((:approx_kfn, approx_kfnLibrary), Bool, ())
  if !success
    # Throw an exception---false means there was a C++ exception.
    throw(ErrorException("mlpack binding error; see output"))
  end
end

" Internal module to hold utility functions. "
module approx_kfn_internal
  import ..approx_kfnLibrary

" Get the value of a model pointer parameter of type ApproxKFNModel."
function CLIGetParamApproxKFNModelPtr(paramName::String)
  return ccall((:CLI_GetParamApproxKFNModelPtr, approx_kfnLibrary), Ptr{Nothing}, (Cstring,), paramName)
end

" Set the value of a model pointer parameter of type ApproxKFNModel."
function CLISetParamApproxKFNModelPtr(paramName::String, ptr::Ptr{Nothing})
  ccall((:CLI_SetParamApproxKFNModelPtr, approx_kfnLibrary), Nothing, (Cstring, Ptr{Nothing}), paramName, ptr)
end

end # module

"""
    approx_kfn(; [algorithm, calculate_error, exact_distances, input_model, k, num_projections, num_tables, query, reference, verbose])

This program implements two strategies for furthest neighbor search. These
strategies are:

 - The 'qdafn' algorithm from "Approximate Furthest Neighbor in High Dimensions"
by R. Pagh, F. Silvestri, J. Sivertsen, and M. Skala, in Similarity Search and
Applications 2015 (SISAP).
 - The 'DrusillaSelect' algorithm from "Fast approximate furthest neighbors with
data-dependent candidate selection", by R.R. Curtin and A.B. Gardner, in
Similarity Search and Applications 2016 (SISAP).

These two strategies give approximate results for the furthest neighbor search
problem and can be used as fast replacements for other furthest neighbor
techniques such as those found in the mlpack_kfn program.  Note that typically,
the 'ds' algorithm requires far fewer tables and projections than the 'qdafn'
algorithm.

Specify a reference set (set to search in) with `reference`, specify a query set
with `query`, and specify algorithm parameters with `num_tables` and
`num_projections` (or don't and defaults will be used).  The algorithm to be
used (either 'ds'---the default---or 'qdafn')  may be specified with
`algorithm`.  Also specify the number of neighbors to search for with `k`.

If no query set is specified, the reference set will be used as the query set. 
The `output_model` output parameter may be used to store the built model, and an
input model may be loaded instead of specifying a reference set with the
`input_model` option.

Results for each query point can be stored with the `neighbors` and `distances`
output parameters.  Each row of these output matrices holds the k distances or
neighbor indices for each query point.

For example, to find the 5 approximate furthest neighbors with `reference_set`
as the reference set and `query_set` as the query set using DrusillaSelect,
storing the furthest neighbor indices to `neighbors` and the furthest neighbor
distances to `distances`, one could call

julia> using CSV
julia> query_set = CSV.read("query_set.csv")
julia> reference_set = CSV.read("reference_set.csv")
julia> distances, neighbors, _ = approx_kfn(algorithm="ds", k=5,
            query=query_set, reference=reference_set)

and to perform approximate all-furthest-neighbors search with k=1 on the set
`data` storing only the furthest neighbor distances to `distances`, one could
call

julia> using CSV
julia> reference_set = CSV.read("reference_set.csv")
julia> distances, _, _ = approx_kfn(k=1, reference=reference_set)

A trained model can be re-used.  If a model has been previously saved to
`model`, then we may find 3 approximate furthest neighbors on a query set
`new_query_set` using that model and store the furthest neighbor indices into
`neighbors` by calling

julia> using CSV
julia> new_query_set = CSV.read("new_query_set.csv")
julia> _, neighbors, _ = approx_kfn(input_model=model, k=3,
            query=new_query_set)

# Arguments

 - `algorithm::String`: Algorithm to use: 'ds' or 'qdafn'.  Default value
      `ds`.
      
 - `calculate_error::Bool`: If set, calculate the average distance error
      for the first furthest neighbor only.  Default value `false`.
      
 - `exact_distances::Array{Float64, 2}`: Matrix containing exact distances
      to furthest neighbors; this can be used to avoid explicit calculation when
      --calculate_error is set.
 - `input_model::unknown_`: File containing input model.
 - `k::Int`: Number of furthest neighbors to search for.  Default value
      `0`.
      
 - `num_projections::Int`: Number of projections to use in each hash
      table.  Default value `5`.
      
 - `num_tables::Int`: Number of hash tables to use.  Default value `5`.

 - `query::Array{Float64, 2}`: Matrix containing query points.
 - `reference::Array{Float64, 2}`: Matrix containing the reference
      dataset.
 - `verbose::Bool`: Display informational messages and the full list of
      parameters and timers at the end of execution.  Default value `false`.
      

# Return values

 - `distances::Array{Float64, 2}`: Matrix to save furthest neighbor
      distances to.
 - `neighbors::Array{Int64, 2}`: Matrix to save neighbor indices to.
 - `output_model::unknown_`: File to save output model to.

"""
function approx_kfn(;
                    algorithm::Union{String, Missing} = missing,
                    calculate_error::Union{Bool, Missing} = missing,
                    exact_distances = missing,
                    input_model::Union{Ptr{Nothing}, Missing} = missing,
                    k::Union{Int, Missing} = missing,
                    num_projections::Union{Int, Missing} = missing,
                    num_tables::Union{Int, Missing} = missing,
                    query = missing,
                    reference = missing,
                    verbose::Union{Bool, Missing} = missing,
                    points_are_rows::Bool = true)
  # Force the symbols to load.
  ccall((:loadSymbols, approx_kfnLibrary), Nothing, ());

  CLIRestoreSettings("Approximate furthest neighbor search")

  # Process each input argument before calling mlpackMain().
  if !ismissing(algorithm)
    CLISetParam("algorithm", convert(String, algorithm))
  end
  if !ismissing(calculate_error)
    CLISetParam("calculate_error", convert(Bool, calculate_error))
  end
  if !ismissing(exact_distances)
    CLISetParamMat("exact_distances", exact_distances, points_are_rows)
  end
  if !ismissing(input_model)
    approx_kfn_internal.CLISetParamApproxKFNModelPtr("input_model", convert(Ptr{Nothing}, input_model))
  end
  if !ismissing(k)
    CLISetParam("k", convert(Int, k))
  end
  if !ismissing(num_projections)
    CLISetParam("num_projections", convert(Int, num_projections))
  end
  if !ismissing(num_tables)
    CLISetParam("num_tables", convert(Int, num_tables))
  end
  if !ismissing(query)
    CLISetParamMat("query", query, points_are_rows)
  end
  if !ismissing(reference)
    CLISetParamMat("reference", reference, points_are_rows)
  end
  if verbose !== nothing && verbose === true
    CLIEnableVerbose()
  else
    CLIDisableVerbose()
  end

  CLISetPassed("distances")
  CLISetPassed("neighbors")
  CLISetPassed("output_model")
  # Call the program.
  approx_kfn_mlpackMain()

  return CLIGetParamMat("distances", points_are_rows),
         CLIGetParamUMat("neighbors", points_are_rows),
         approx_kfn_internal.CLIGetParamApproxKFNModelPtr("output_model")
end
