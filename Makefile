# SPDX-FileCopyrightText: 2024 Henrik Sandklef
#
# SPDX-License-Identifier: GPL-3.0-or-later

clean:
	find . -name "*~" | xargs rm -f
	rm -fr licomp_dwheeler.egg-info
	rm -fr build
	rm -fr licomp_dwheeler/__pycache__
	rm -fr tests/__pycache__
	rm -f *.csv
	rm -fr dist
	rm -f *.dot

lint:
	PYTHONPATH=. flake8 licomp_dwheeler

check_version:
	@echo -n "Checking api versions: "
	@MY_VERSION=`grep api_version licomp_dwheeler/config.py | cut -d = -f 2 | sed -e "s,[ ']*,,g"` ; LICOMP_VERSION=`grep licomp requirements.txt | cut -d = -f 3 | sed -e "s,[ ']*,,g" -e "s,[ ']*,,g" -e "s,\(^[0-9].[0-9]\)[\.0-9\*]*,\1,g"` ; if [ "$$MY_VERSION" != "$$LICOMP_VERSION" ] ; then echo "FAIL" ; echo "API versions differ \"$$MY_VERSION\" \"$$LICOMP_VERSION\"" ; exit 1 ; else echo OK ; fi

.PHONY: build
build:
	rm -fr build && python3 setup.py sdist

test:
	PYTHONPATH=. python3 -m pytest --log-cli-level=10 tests/

test-local:
	PYTHONPATH=.:../licomp python3 -m pytest --log-cli-level=10 tests/

install:
	pip install .

reuse:
	reuse lint

licomp-dwheeler.dot:
	devel/json2dot > $@

licomp-dwheeler.png: licomp-dwheeler.dot
	dot $< -Tpng -o licomp-dwheeler.png

graph: licomp-dwheeler.png

check: clean reuse lint test check_version build
	@echo
	@echo
	@echo "All tests passed :)"
	@echo
	@echo
