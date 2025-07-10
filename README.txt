
The files required to run the slug model:
SlugModel3D.m - this is the main file to use to run the model, all parameters can be changed in the first section of this code.
nextstep3D.m - this function generates the new position of all slugs at each time step.
circ_vmrnd.m - this is used to generate a random number from the Von Mises distribution, see https://uk.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics
SlugBinning.m - this function takes the coordinates of slugs and calculates correlation coefficients and range from minimum to maximum bin size.

UPDATE TO SlugBinning.m - this function will now also plot the position of slugs and their distribution underground and aboveground and save them into a folder called 'Figures' (which needs to be created manually first)

Inputs:
The parameters in the first section of SlugModel3D.m are all labelled and can be changed. 
For a single simulation, set Nk=1. For multiple simulations (Nk>1) the outputs will be the mean from all simulations.
The initial condition indicator I0 should be set to either 1 (uniform initial distribution) or 2 (load previous distribution).
If I0=2, a file name for the previous distribution should be input to the 'InitialFile' parameter (either .mat or .txt file will work).


Outputs:
The outputs are saved as Matlab workspaces and txt files. They are labelled 'ModelOutputs_*name*' where *name* is be replaced by the 'name' parameter at the start of the code.

The outputs are a table where the columns represent:
 correlation coefficient (Corr), bin range underground (Brange(1)), bin range overground (Brange(2)), number of slugs overground (Nu), number of slugs underground (Nd).

The rows show the values at each time interval (Tint) which can be changed. The first entry will be at time t=Tint and the last entry will be at t=Tmax.

A second output is the final position of all slugs labelled 'LastPosition_*name*', similarly to the model outputs file. 
If multiple repeats are done (Nk>1) then only positions from the final simulation are recorded.
Columns represent: Xfin, Yfin, Ufin, th, 
where Ufin=0/1 represents underground/overground and th is the direction of their final step (needed for the correlated random walk of sparse slugs).



Variable vertical movement probability:
SlugModel3D_VariableVerticalMovement.m - An updated version of the main file: SlugModel3D.m 
The vertical movement probabilities VMu and VMd are now functions instead of parameters but can be edited in the same way.
The rest of the files are unchanged and work the same way with the main file. 
This version also plots the outputs over time and saves them in a 'Figures' folder (which needs to be created manually first) in pdf and matlab figure formats. Delete the final section of code if this is not needed.