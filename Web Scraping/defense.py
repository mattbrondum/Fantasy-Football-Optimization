import requests
from lxml import html 
import os
import pandas as pd

import numpy as np
import csv


def get_defense():
	 url="https://www.pro-football-reference.com/years/%d/opp.htm" % 2002
