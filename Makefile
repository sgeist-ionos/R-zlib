.PHONY: clean docs

R_PROFILE = .Rprofile

all: clean
	gcc -v

clean:
	rm -rf dist
	rm -f **/*.so **/*.o **/RcppExports.cpp

.compile:
	@Rscript -e "install.packages('devtools')"
	@Rscript -e "devtools::document()"
	@Rscript -e "devtools::install_dev_deps()"
	@Rscript -e "Rcpp::compileAttributes()"
	@Rscript -e "renv::restore()"

check:
	cppcheck src --error-exitcode=1
	@Rscript -e "devtools::check(cran=TRUE)"

docs: coverage
	@rm html -rf
	@Rscript -e "devtools::document()"
	@Rscript docs/generate_docs.R
	@Rscript -e 'if (file.exists("html/index.html")) browseURL("html/index.html")'

build: clean .compile
	# build into dist/<package-name> folder with devtools
	@mkdir -p dist
	@Rscript -e "devtools::build( path = 'dist' )"

build-check: build
	@R CMD check --as-cran dist/zlib*

test:
	@Rscript -e "testthat::test_dir('tests')"

coverage:
	@Rscript -e "covr::report(file = 'html/coverage.html')"

install: clean .compile
	@Rscript -e "devtools::install()"

install-fast:
	R CMD INSTALL .