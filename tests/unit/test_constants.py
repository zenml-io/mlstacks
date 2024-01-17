#  Copyright (c) ZenML GmbH 2023. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  or implied. See the License for the specific language governing
#  permissions and limitations under the License.


import re

from hypothesis import given
from hypothesis import strategies as st

from mlstacks.constants import PERMITTED_NAME_REGEX


@given(st.from_regex(PERMITTED_NAME_REGEX))
def test_name_regex_works_as_expected(sample_name: str):
    assert re.match(PERMITTED_NAME_REGEX, sample_name)
    assert re.match(PERMITTED_NAME_REGEX, sample_name.upper())
    assert re.match(PERMITTED_NAME_REGEX, sample_name.lower())
    assert re.match(PERMITTED_NAME_REGEX, "aria")
    assert re.match(PERMITTED_NAME_REGEX, "aria-aria")
    assert re.match(PERMITTED_NAME_REGEX, "aria-")
    assert not re.match(PERMITTED_NAME_REGEX, "-aria")
    assert not re.match(PERMITTED_NAME_REGEX, "")
