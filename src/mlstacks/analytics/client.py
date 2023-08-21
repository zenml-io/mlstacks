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
"""Analytics module for MLStacks."""

import datetime

import segment.analytics as analytics

analytics.write_key = "tU9BJvF05TgC29xgiXuKF7CuYP0zhgnx"

user_id = "f4ca124298"
analytics.identify(
    user_id,
    {
        "name": "Alex Strick van Linschoten",
        "email": "alex.ext@zenml.io",
        "created_at": datetime.datetime.now(),
    },
)

# analytics.track(
#     user_id,
#     AnalyticsEventsEnum.MLSTACKS_SOURCE,
#     {
#         "python_version": python_version(),
#     },
# )
