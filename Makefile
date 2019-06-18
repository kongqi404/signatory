.PHONY: genreadme test docs publish prepublish buildandtest
.RECIPEPREFIX+=

# generate the readme from the documentation
genreadme:
    python genreadme.py

# run tests
test:
    python -m test.runner

# make docs
docs:
    sphinx-build -M html ./docs ./docs/_build


# push to pypi
publish:
    twine upload dist/*

# build and test everything
prepublish:
    @( \
    set -e ;\
    rm -rf dist ;\
    make -s genreadme ;\
    VERSION=$$(python -c "import metadata; print(metadata.version)") ;\
    python setup.py sdist > /dev/null  ;\
    make --no-print-directory O=2.7 DIST=signatory-$${VERSION}-cp27-cp27mu-linux_x86_64.whl buildandtest ;\
    make --no-print-directory O=3.5 DIST=signatory-$${VERSION}-cp35-cp35m-linux_x86_64.whl buildandtest ;\
    make --no-print-directory O=3.6 DIST=signatory-$${VERSION}-cp36-cp36m-linux_x86_64.whl buildandtest ;\
    make --no-print-directory O=3.7 DIST=signatory-$${VERSION}-cp37-cp37m-linux_x86_64.whl buildandtest ;\
    make --no-print-directory O=2.7 DIST=signatory-$${VERSION}.tar.gz buildandtest ;\
    make --no-print-directory O=3.5 DIST=signatory-$${VERSION}.tar.gz buildandtest ;\
    make --no-print-directory O=3.6 DIST=signatory-$${VERSION}.tar.gz buildandtest ;\
    make --no-print-directory O=3.7 DIST=signatory-$${VERSION}.tar.gz buildandtest ;\
    )


#### Not to call directly ####

# build and test on a particular version
buildandtest:
    @( \
    set -e ;\
    conda create --prefix=/tmp/signatory-$${O} -y python=$${O} > /dev/null  ;\
    . ~/miniconda3/etc/profile.d/conda.sh > /dev/null ;\
    conda activate /tmp/signatory-$${O} > /dev/null  ;\
    conda install -y pytorch==1.0.1 -c pytorch > /dev/null  ;\
    python setup.py bdist_wheel > /dev/null  ;\
    pip install dist/$${DIST} > /dev/null  ;\
    pip install iisignature > /dev/null  ;\
    echo version=$${O} ;\
    make --no-print-directory test ;\
    conda deactivate ;\
    conda env remove -p /tmp/signatory-$${O} > /dev/null  ;\
    )