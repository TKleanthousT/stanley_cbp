"""
STANLEY: Circumbinary Planet Detection Package
"""

# Package version
__version__ = "0.1.44"

# Public API imports
from . import Stanley_PlanetSearch_InterpN_DebugPadding as SFP
from .Stanley_Analysis_InterpN import runAnalysisModule
from . import Stanley_Functions as AC
from . import Stanley_TransitTiming as SSTT
from .Stanley_Detrending import runDetrendingModule
