export random_forest

using mlpack.util.cli

import mlpack_jll
const random_forestLibrary = mlpack_jll.libmlpack_julia_random_forest

# Call the C binding of the mlpack random_forest binding.
function random_forest_mlpackMain()
  success = ccall((:random_forest, random_forestLibrary), Bool, ())
  if !success
    # Throw an exception---false means there was a C++ exception.
    throw(ErrorException("mlpack binding error; see output"))
  end
end

" Internal module to hold utility functions. "
module random_forest_internal
  import ..random_forestLibrary

" Get the value of a model pointer parameter of type RandomForestModel."
function CLIGetParamRandomForestModelPtr(paramName::String)
  return ccall((:CLI_GetParamRandomForestModelPtr, random_forestLibrary), Ptr{Nothing}, (Cstring,), paramName)
end

" Set the value of a model pointer parameter of type RandomForestModel."
function CLISetParamRandomForestModelPtr(paramName::String, ptr::Ptr{Nothing})
  ccall((:CLI_SetParamRandomForestModelPtr, random_forestLibrary), Nothing, (Cstring, Ptr{Nothing}), paramName, ptr)
end

end # module

"""
    random_forest(; [input_model, labels, maximum_depth, minimum_gain_split, minimum_leaf_size, num_trees, print_training_accuracy, seed, subspace_dim, test, test_labels, training, verbose])

This program is an implementation of the standard random forest classification
algorithm by Leo Breiman.  A random forest can be trained and saved for later
use, or a random forest may be loaded and predictions or class probabilities for
points may be generated.

The training set and associated labels are specified with the `training` and
`labels` parameters, respectively.  The labels should be in the range [0,
num_classes - 1]. Optionally, if `labels` is not specified, the labels are
assumed to be the last dimension of the training dataset.

When a model is trained, the `output_model` output parameter may be used to save
the trained model.  A model may be loaded for predictions with the
`input_model`parameter. The `input_model` parameter may not be specified when
the `training` parameter is specified.  The `minimum_leaf_size` parameter
specifies the minimum number of training points that must fall into each leaf
for it to be split.  The `num_trees` controls the number of trees in the random
forest.  The `minimum_gain_split` parameter controls the minimum required gain
for a decision tree node to split.  Larger values will force higher-confidence
splits.  The `maximum_depth` parameter specifies the maximum depth of the tree. 
The `subspace_dim` parameter is used to control the number of random dimensions
chosen for an individual node's split.  If `print_training_accuracy` is
specified, the calculated accuracy on the training set will be printed.

Test data may be specified with the `test` parameter, and if performance
measures are desired for that test set, labels for the test points may be
specified with the `test_labels` parameter.  Predictions for each test point may
be saved via the `predictions`output parameter.  Class probabilities for each
prediction may be saved with the `probabilities` output parameter.

For example, to train a random forest with a minimum leaf size of 20 using 10
trees on the dataset contained in `data`with labels `labels`, saving the output
random forest to `rf_model` and printing the training error, one could call

julia> using CSV
julia> data = CSV.read("data.csv")
julia> labels = CSV.read("labels.csv"; type=Int64)
julia> rf_model, _, _ = random_forest(labels=labels,
            minimum_leaf_size=20, num_trees=10, print_training_accuracy=1,
            training=data)

Then, to use that model to classify points in `test_set` and print the test
error given the labels `test_labels` using that model, while saving the
predictions for each point to `predictions`, one could call 

julia> using CSV
julia> test_set = CSV.read("test_set.csv")
julia> test_labels = CSV.read("test_labels.csv"; type=Int64)
julia> _, predictions, _ = random_forest(input_model=rf_model,
            test=test_set, test_labels=test_labels)

# Arguments

 - `input_model::unknown_`: Pre-trained random forest to use for
      classification.
 - `labels::Array{Int64, 1}`: Labels for training dataset.
 - `maximum_depth::Int`: Maximum depth of the tree (0 means no limit). 
      Default value `0`.
      
 - `minimum_gain_split::Float64`: Minimum gain needed to make a split when
      building a tree.  Default value `0`.
      
 - `minimum_leaf_size::Int`: Minimum number of points in each leaf node. 
      Default value `1`.
      
 - `num_trees::Int`: Number of trees in the random forest.  Default value
      `10`.
      
 - `print_training_accuracy::Bool`: If set, then the accuracy of the model
      on the training set will be predicted (verbose must also be specified). 
      Default value `false`.
      
 - `seed::Int`: Random seed.  If 0, 'std::time(NULL)' is used.  Default
      value `0`.
      
 - `subspace_dim::Int`: Dimensionality of random subspace to use for each
      split.  '0' will autoselect the square root of data dimensionality. 
      Default value `0`.
      
 - `test::Array{Float64, 2}`: Test dataset to produce predictions for.
 - `test_labels::Array{Int64, 1}`: Test dataset labels, if accuracy
      calculation is desired.
 - `training::Array{Float64, 2}`: Training dataset.
 - `verbose::Bool`: Display informational messages and the full list of
      parameters and timers at the end of execution.  Default value `false`.
      

# Return values

 - `output_model::unknown_`: Model to save trained random forest to.
 - `predictions::Array{Int64, 1}`: Predicted classes for each point in the
      test set.
 - `probabilities::Array{Float64, 2}`: Predicted class probabilities for
      each point in the test set.

"""
function random_forest(;
                       input_model::Union{Ptr{Nothing}, Missing} = missing,
                       labels = missing,
                       maximum_depth::Union{Int, Missing} = missing,
                       minimum_gain_split::Union{Float64, Missing} = missing,
                       minimum_leaf_size::Union{Int, Missing} = missing,
                       num_trees::Union{Int, Missing} = missing,
                       print_training_accuracy::Union{Bool, Missing} = missing,
                       seed::Union{Int, Missing} = missing,
                       subspace_dim::Union{Int, Missing} = missing,
                       test = missing,
                       test_labels = missing,
                       training = missing,
                       verbose::Union{Bool, Missing} = missing,
                       points_are_rows::Bool = true)
  # Force the symbols to load.
  ccall((:loadSymbols, random_forestLibrary), Nothing, ());

  CLIRestoreSettings("Random forests")

  # Process each input argument before calling mlpackMain().
  if !ismissing(input_model)
    random_forest_internal.CLISetParamRandomForestModelPtr("input_model", convert(Ptr{Nothing}, input_model))
  end
  if !ismissing(labels)
    CLISetParamURow("labels", labels)
  end
  if !ismissing(maximum_depth)
    CLISetParam("maximum_depth", convert(Int, maximum_depth))
  end
  if !ismissing(minimum_gain_split)
    CLISetParam("minimum_gain_split", convert(Float64, minimum_gain_split))
  end
  if !ismissing(minimum_leaf_size)
    CLISetParam("minimum_leaf_size", convert(Int, minimum_leaf_size))
  end
  if !ismissing(num_trees)
    CLISetParam("num_trees", convert(Int, num_trees))
  end
  if !ismissing(print_training_accuracy)
    CLISetParam("print_training_accuracy", convert(Bool, print_training_accuracy))
  end
  if !ismissing(seed)
    CLISetParam("seed", convert(Int, seed))
  end
  if !ismissing(subspace_dim)
    CLISetParam("subspace_dim", convert(Int, subspace_dim))
  end
  if !ismissing(test)
    CLISetParamMat("test", test, points_are_rows)
  end
  if !ismissing(test_labels)
    CLISetParamURow("test_labels", test_labels)
  end
  if !ismissing(training)
    CLISetParamMat("training", training, points_are_rows)
  end
  if verbose !== nothing && verbose === true
    CLIEnableVerbose()
  else
    CLIDisableVerbose()
  end

  CLISetPassed("output_model")
  CLISetPassed("predictions")
  CLISetPassed("probabilities")
  # Call the program.
  random_forest_mlpackMain()

  return random_forest_internal.CLIGetParamRandomForestModelPtr("output_model"),
         CLIGetParamURow("predictions"),
         CLIGetParamMat("probabilities", points_are_rows)
end
