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
import datetime
import os
from uuid import uuid4
from mlstacks.analytics.client import (
    get_analytics_user_id,
    set_analytics_user_id,
)
import segment.analytics as analytics

analytics.write_key = "tU9BJvF05TgC29xgiXuKF7CuYP0zhgnx"

if (
    not os.environ.get("MLSTACKS_ANALYTICS_OPT_OUT")
    and not get_analytics_user_id()
):
    user_id = str(uuid4())
    set_analytics_user_id(user_id)
    analytics.identify(
        user_id,
        {
            "created_at": datetime.datetime.now(),
        },
    )
