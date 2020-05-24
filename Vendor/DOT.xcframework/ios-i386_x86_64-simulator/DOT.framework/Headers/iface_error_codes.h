/* This header file contains list of all possible IFace SDK
   Error codes.                                             */
#ifndef _IFACE_ERROR_CODES_H
#define _IFACE_ERROR_CODES_H

//%<InnoDoc id=errors_desc>
//% Each IFace SDK function returns one of following error codes.
//%
//% <b>NOTE: </b>Error codes between 50000 and 50100 are related to licensing errors. 
//% Please use API function IFACE_GetErrorMessage to get more information about the error.
//%</InnoDoc>

//%<InnoTable id=errors>
#define IFACE_OK                           0     // No error

#define IFACE_ERR_GENERIC                101     // Generic IFace error
#define IFACE_ERR_MEMORY_GENERIC         102     // Generic memory error  
#define IFACE_ERR_INIT_GENERIC           103     // Generic initialization error
#define IFACE_ERR_PARAM_GENERIC          104     // Generic invalid parameter error
#define IFACE_ERR_IO_GENERIC             105     // Generic IO error
#define IFACE_ERR_LICENSE_INTEGRATION_GENERIC 106     // Generic License error

#define IFACE_ERR_ALGORITHM_GENERIC      108     // Generic IFace algorithm error
#define IFACE_ERR_VERIFICATION_GENERIC   109     // Generic IFace verification error
#define IFACE_ERR_TRACKING_GENERIC       110     // Generic IFace tracking error
#define IFACE_ERR_LIVENESS_GENERIC       111     // Generic IFace liveness error
#define IFACE_ERR_OTHER_GENERIC          199     // Generic other error

#define IFACE_ERR_MEMORY_READ_FROM_NULL  201     // Read from NULL pointer

#define IFACE_ERR_INIT_ENTITY            301     // IFace entity initialization error
#define IFACE_ERR_INIT_SOLVER            302     // Solver initialization error
#define IFACE_ERR_INIT_CASCADE           303     // Cascade Solver initialization error
#define IFACE_ERR_INIT_NUM_FACES         304     // Wrong number of face entities per face handler entity (min. 1, max. 64)

#define IFACE_ERR_PARAM_FACE_HANDLER     401     // Invalid face handler entity error
#define IFACE_ERR_PARAM_FACE             402     // Invalid face entity error
#define IFACE_ERR_PARAM_FEATURE          403     // Invalid face features or eye-distance
#define IFACE_ERR_PARAM_IMAGE_FORMAT     404     // Unsupported image format error
#define IFACE_ERR_PARAM_FACE_SIZE        406     // Invalid face size error (too big or too small face-size)
#define IFACE_ERR_PARAM_USER             407     // Invalid user parameter error
#define IFACE_ERR_PARAM_NORM             408     // Data normalization error
#define IFACE_ERR_PARAM_OUT_OF_IMAGE     409     // Falling outside the image boundaries
#define IFACE_ERR_PARAM_INDEX_OUT        410     // Index out of bounds
#define IFACE_ERR_PARAM_BUFFER_SIZE      411     // Buffer size allocated is not sufficient
#define IFACE_ERR_PARAM_READ_ONLY        412     // Can't set read-only parameter
#define IFACE_ERR_PARAM_NO_SCORE         413     // Can't get score or ICAO compliance range status from face attribute (e.g. crop, age, segmentation mask etc.)
#define IFACE_ERR_PARAM_CONDITION_SYNTAX 414     // Syntax error in face attribute condition parameter
#define IFACE_ERR_PARAM_GPU_DEVICE_NOT_AVAILABLE 415     // Can't enable selected CUDA device
#define IFACE_ERR_PARAM_INVALID_PARAM_VALUE 416  // Invalid parameter value
#define IFACE_ERR_PARAM_NOT_FOUND        417     // Parameter not found
#define IFACE_ERR_PARAM_ENTITY           418     // Invalid entity
#define IFACE_ERR_PARAM_TRACKING_MASK    419     // Tracking mask is not valid (e.g. only zero values)

#define IFACE_ERR_IO_LOAD_FILE           501     // Can't read file
#define IFACE_ERR_IO_SAVE_EXISTS         502     // Saving to file which already exists
#define IFACE_ERR_IO_SAVE_EMPTY          503     // Saving empty data
#define IFACE_ERR_IO_RENAME              504     // Error when renaming file
#define IFACE_ERR_IO_SAVE_FAILS          505     // Saving failed

#define IFACE_ERR_LICENSE_ALREADY_INITIALIZED     601 // License was already initialized
#define IFACE_ERR_LICENSE_ALREADY_UNINITIALIZED   602 // License was already uninitialized

#define IFACE_ERR_ALGORITHM_UNINITIALIZED   801  // Uninitialized variable error
#define IFACE_ERR_ALGORITHM_WRONG_PARAM     802  // Wrong input parameter
#define IFACE_ERR_ALGORITHM_NOT_AVAILABLE   803  // Functionality is not implemented yet or is disabled. Please check <b>IFace editions features and platforms</b> section in IFace SDK documentation.

#define IFACE_ERR_VERIFICATION_VERSION      901  // \Face verification template of this version is not supported
#define IFACE_ERR_VERIFICATION_INCOMPATIBLE 902  // Incompatible version of face verification templates
#define IFACE_ERR_VERIFICATION_CORRUPTED    903  // \Face verification template is corrupted

#define IFACE_ERR_TRACKING_FACE_NOT_AVAILABLE            1001  // \Face entity can't be extracted from the object entity
#define IFACE_ERR_TRACKING_INCONSISTENT_IMAGE_DIMENSIONS 1002  // The dimensions of the current tracking image don't match with the dimensions of the previous images or the tracking mask

#define IFACE_ERR_LIVENESS_DOT_POSITION_REDUNDANT_DEFINITION    1101 // Multiple dot position were defined, but corresponding frames were not set (<c>IFACE_SetLivenessDotPosition</c> was not followed by <c>IFACE_TrackObjects</c> call)
#define IFACE_ERR_LIVENESS_DOT_POSITION_NOT_VALID               1102 // Invalid screen dot position was set
#define IFACE_ERR_LIVENESS_NO_FACE                              1103 // No face detected
#define IFACE_ERR_LIVENESS_TOO_MANY_FACES                       1104 // Too many faces detected

#define IFACE_ERR_OTHER_IMGPROC         9901     // Other image processing error
#define IFACE_ERR_OTHER_DATPROC         9902     // Other data processing error

//%</InnoTable>


#endif //_IFACE_ERROR_CODES_H
