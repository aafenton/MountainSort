# packages

**utilities:**\
matlab scripts for analysis and sorting

**mountainsort3.mlp:**\
The mountainsort pipeline to use when generating command_sort (in run_one.m, terminal command for sorting)

**spec.cpp:**\
Just a copy of the sorting script inside the mountainsort3.mlp, so that we can view it directly.\
The "param" listed there can be passed through the command_sort.\
If not specified, the default values there will be used.

## Install MountainSort for clips

- Follow the instrustion here for advanced installation (with compilation)

  https://mountainsort.readthedocs.io/en/latest/installation_advanced.html
  
- Replace the packages before compiling mountainsort
```
  cd ~/mountainlab/packages/mountainsort
  rm -r packages
  git clone https://github.com/aafenton/MountainSort.git packages
  ./compile_components.sh
```
- Add path, in my case I do the following
```
    gedit ~/.bashrc
    export PATH=$PATH:~/mountainlab/packages/mountainview/bin
    export PATH=$PATH:~/mountainlab/packages/mlpipeline/bin
    export PATH=$PATH:~/mountainlab/bin
```
- Set tmp directory to place with enough space
