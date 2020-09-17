FROM quay.io/uninett/jupyterhub-singleuser:20200519-4d8716b

MAINTAINER Anne Fouilloux <annefou@geo.uio.no>

# Install packages
USER root
RUN apt-get update && apt-get install -y vim

# Install requirements for Python 3
ADD jupyterhub_environment.yml jupyterhub_environment.yml

RUN conda env update -f jupyterhub_environment.yml

RUN /opt/conda/bin/jupyter labextension install @jupyterlab/hub-extension @jupyter-widgets/jupyterlab-manager
RUN /opt/conda/bin/nbdime extensions --enable
RUN /opt/conda/bin/jupyter labextension install jupyterlab-datawidgets nbdime-jupyterlab dask-labextension
RUN /opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-sidecar
RUN /opt/conda/bin/jupyter serverextension enable jupytext
RUN /opt/conda/bin/jupyter nbextension install --py jupytext
RUN /opt/conda/bin/jupyter nbextension enable --py jupytext

# Install requirements for cesm 
ADD cesm_environment.yml cesm_environment.yml

# Python packages
RUN conda env create -f cesm_environment.yml && conda clean -yt
RUN ["/bin/bash" , "-c", ". /opt/conda/etc/profile.d/conda.sh && \
    conda activate cesm && \
    python -m pip install ipykernel && \
    ipython kernel install --name cesm && \
    python -m ipykernel install --name=cesm && \
    jupyter labextension install @jupyterlab/hub-extension \
            @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyterlab-datawidgets && \
    conda deactivate && \
    conda init bash"]

# Install requirements for pangeo 
ADD pangeo_environment.yml pangeo_environment.yml

# Python packages
RUN conda env create -f pangeo_environment.yml && conda clean -yt
RUN ["/bin/bash" , "-c", ". /opt/conda/etc/profile.d/conda.sh && \
    conda activate pangeo && \
    python -m pip install ipykernel && \
    ipython kernel install --name pangeo && \
    python -m ipykernel install --name=pangeo && \
    jupyter labextension install @jupyterlab/hub-extension \
            @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyterlab-datawidgets && \
    conda deactivate && \
    conda init bash"]

# Install requirements for esmvaltool 
ADD esmvaltool_environment.yml esmvaltool_environment.yml

# Python packages
RUN conda env create -f esmvaltool_environment.yml && conda clean -yt
RUN ["/bin/bash" , "-c", ". /opt/conda/etc/profile.d/conda.sh && \
    conda activate esmvaltool && \
    python -m pip install ipykernel && \
    ipython kernel install --name esmvaltool && \
    python -m ipykernel install --name=esmvaltool && \
    jupyter labextension install @jupyterlab/hub-extension \
            @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyterlab-datawidgets && \
    conda deactivate && \
    conda init bash"]

# fix permission problems (hub is then failing)
RUN fix-permissions $HOME

# Install other packages
USER notebook
