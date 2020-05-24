// This header file contains list of all IFace SDK user paramters. Face SDK API Functions <c>IFACE_SetParam</c>, 
// <c>IFACE_GetParamSize</c> and <c>IFACE_GetParam</c> can be used for getting and setting of the user parameters.
#ifndef _IFACE_PARAMS_NAMES_H_
#define _IFACE_PARAMS_NAMES_H_

//%<InnoDoc id=parameters_desc>
//% IFace SDK has various internal parameters. Some of parameters can be adjusted to change behavior of IFace SDK.
//% These parameters has its name and default values.  
//%
//% There are two main types of parameters:
//%
//%   * global parameters valid for whole IFace SDK
//%
//%   * entity parameters valid just within certain types of entities.
//%
//% IFace SDK API Functions <c>IFACE_SetParam</c>, <c>IFACE_GetParamSize</c> and <c>IFACE_GetParam</c> can be  
//% used for getting and setting of the parameters. Names of parameters are strings as well as their values.
//%</InnoDoc>

//%<InnoDoc id=parameters_global_desc>
//% Global parameters are valid for whole IFace, not just within entities.
//% So, in case of global parameters, functions <c>IFACE_SetParam</c>, <c>IFACE_GetParamSize</c> and <c>IFACE_GetParam</c> 
//% must be called with <c>IFACE_GLOBAL_PARAMETERS</c> standing for <c>entity</c> parameter. 
//% Global parameters can be set only before calling <c>IFACE_Init</c> or after calling <c>IFACE_Terminate</c>.
//% Global parameters are switched to read-only mode after <c>IFACE_Init</c> and before <c>IFACE_Terminate</c>.
//%</InnoDoc>

#define IFACE_PARAMETER_GLOBAL_THREAD_NUM              "global.thrd.num"             // Parameter defining maximum number of parallel threads used within one entity.
                                                                                     // <p><i>Note: Valid range of values <1,64></i>
                                                                                     // <p><i>Value type</i>: Integer, Read-Write

#define IFACE_PARAMETER_GLOBAL_THREAD_MANAGEMENT_MODE  "global.thrd.management_mode" // Parameter defining multi-threading mode (trade-off between speed and memory usage)
                                                                                     // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_GLOBAL_GPU_ENABLED             "global.gpu.enabled"          // Parameter defining if the CUDA GPU acceleration is enabled. 
                                                                                     // <p><i>Note: works only with special CUDA GPU optimized version of IFace</i>
                                                                                     // <p><i>Value type</i>: Boolean, Read-Write

#define IFACE_PARAMETER_GLOBAL_GPU_DEVICE_ID           "global.gpu.device_id"        // Parameter defining the device id which will be used for GPU CUDA computations
                                                                                     // <p><i>Note: works only if CUDA GPU optimization enabled and with special CUDA 
                                                                                     // GPU optimized version of IFace</i>
                                                                                     // <p><i>Value type</i>: Integer, Read-Write

#define IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE    "global.fd.min_valid_image_size"  // Parameter specifying minimal valid size (width or height) of image accepted by IFace.
                                                                                         // <p><i>Value type</i>: Integer, Read-Only

//%<InnoDoc id=parameters_entity_desc>
//% Entity parameters are valid just within the entity. Each entity can have its own set of parameters if necessary.
//% So, in case of entity parameters, functions <c>IFACE_SetParam</c>, <c>IFACE_GetParamSize</c> and <c>IFACE_GetParam</c> 
//% must be called with valid entity pointer standing for <c>entity</c> parameter.
//%</InnoDoc>

//%<InnoDoc id=parameters_face_processing_desc>
//% Parameters specifying behavior of Face processing API functions. They are stored within face handler entity.
//%</InnoDoc>
#define IFACE_PARAMETER_FACEDET_SPEED_ACCURACY_MODE    "fd.speed_accuracy_mode"     // Parameter defining face detection mode.
                                                                                    // It represents trade-off between face and facial features detection speed and accuracy.
                                                                                    // Change of this parameter changes value of parameter <c>IFACE_PARAMETER_FACEDET_CONFIDENCE_THRESHOLD<c>
                                                                                    // because each mode has its own optimal threshold
                                                                                    // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_FACEDET_CONFIDENCE_THRESHOLD    "fd.face_confidence_threshold"  // Parameter defining minimal detections score.
                                                                                        // Setting <c>IFACE_PARAMETER_FACEDET_SPEED_ACCURACY_MODE<c> may change its value.
                                                                                        // Internal detections with lower score will not be returned from SDK
                                                                                        // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_MIN_VALID_FACE_SIZE     "fd.min_valid_face_size"   // Parameter specifying minimal valid size of face which is detectable by IFace in current detection mode.
                                                                           // \Face size is given by maximum of eyes distance and eyes to mouth distance in image.
                                                                           // It is measured in pixels.
                                                                           // <p><i>Value type</i>: Integer, Read-Only

#define IFACE_PARAMETER_FACETMPLEXT_SPEED_ACCURACY_MODE  "fte.speed_accuracy_mode"    // Parameter defining face template extraction mode.
                                                                                      // It represents trade-off between face template creation speed and face template quality.
                                                                                      // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_AGEGENDER_SPEED_ACCURACY_MODE  "ag.speed_accuracy_mode"     // Parameter defining age and gender evaluation mode.
                                                                                    // It represents trade-off between
                                                                                    // age and gender evaluation speed and precision of the age and gender predictions.
                                                                                    // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_BACKGROUND_COLOR               "img.background_color"       // Parameter defining color which is used to fill in parts of cropped image that 
                                                                                    // fall outside the original source image boundaries. 
                                                                                    // Valid value is hexadecimal code string e.g. "RRGGBB".
                                                                                    // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_GET_LIST_OF_ALL_PARAMS         "pa.get_list_of_all_params"  // Parameter containing all available parameters names.
                                                                                    // <p><i>Value type</i>: String, Read-Only

#define IFACE_PARAMETER_FACE_CROP_FULLFRONTAL_EXTENDED_SCALE  "img.face_crop_full_frontal_extended_scale" // Parameter defining amount of background image area enlargement of fully-frontal cropped facial image.
                                                                                                          // <p><i>Value type</i>: Int, Read-Write

#define IFACE_PARAMETER_FACE_CROP_TOKEN_FRONTAL_EXTENDED_SCALE  "img.face_crop_token_frontal_extended_scale" // Parameter defining amount of background image area enlargement of token-frontal cropped facial image.
                                                                                                             // <p><i>Value type</i>: Int, Read-Write

#define IFACE_PARAMETER_SEGMENTATION_MATTING_TYPE          "hss.matting_type"       // Parameter defining type of matting used after head shoulder segmentation.
                                                                                    // <p><i>Value type</i>: String, Read-Write

#define IFACE_PARAMETER_FACE_DET_MAX_IMAGE_SIZE            "fd.max_image_size"      // Parameter affecting 'balanced'/'accurate'/'accurate_server' face detection mode.
                                                                                    // It defines maximal image size of image entering to internal solver.
                                                                                    // If you have limited resources (e.g. memory or GPU memory), you will probably have to set this parameter to lower value.
                                                                                    // The value of this param also affects minFaceSize that can be set-up.
                                                                                    // Simply said, if you set this value to higher number, you will be able to set the minFaceSize to smaller value and you will be able to detect smaller faces.
                                                                                    // The constrain for possible minFaceSize can be formulated as follows:
                                                                                    //  `minFaceSize >= 10 * max(in_img.width, in_img.height) / IFACE_PARAMETER_FACE_DET_MAX_IMAGE_SIZE
                                                                                    // <p><i>Value type</i>: String, Read-Write

//%<InnoDoc id=parameters_faceattr_cond_desc>
//% Names of parameters containing definitions of face attribute reliability conditions.
//% These condition are evaluated in IFACE_GetFaceAttributeDependenciesStatus and IFACE_GetIcaoComplianceStatus and use following syntax:
//%
//% - For features with score: <c>"FT:(FT_low;FT_high)[&&DEP1[:(DEP1_low;DEP1_high)][&&DEP2...[&&DEPn[:(DEPn_low;DEPn_high)]]]]"</c>
//%
//% - For features without score: <c>"[DEP1[:(DEP1_low;DEP1_high)][&&DEP2...[&&DEPn[:(DEPn_low;DEPn_high)]]]]"</c>
//%
//% Where:	
//%
//%  - FT is name of desired feature (face attribute)
//%
//%  - (FT_low;FT_high) is reliability range for desired feature score  
//%
//%  - DEP1..DEPn are names of features that desired feature depends on
//%
//%  - (DEPx_low;DEPx_high) is reliability range of DEPx feature score 
//%
//% Notes: 
//%
//%  - Ranges can use any combination of two types of brackets - () and <>, 
//%    where '()' defines an open interval and '<>' defines a closed interval.  
//%
//%  - DEPx must be feature producing score (numeric value). 
//%
//%  - It is not necessary for DEPx to have a range defined. If the range is not 
//%    defined for DEPx in dependencies specification, and only name of feature DEPx
//%    figures there, then range of desired feature having name of DEPX is used instead.
//%
//%  - Make sure to avoid loops in dependencies (FT1 depends on FT2 and FT2 depends on FT1).
//%
//%  - Please note that it is not recommended to change IFACE_PARAMETER_ICAO_COND_* parameters without serious reason.
//%
//% Examples:
//%   See valid examples in IFACE_PARAMETER_FACE_ATTRIBUTE_COND_*_DEFAULT
//%</InnoDoc>

#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SHARPNESS                "faceattr.condition.sharpness"               // Parameter defining reliability condition and dependencies for facial sharpness
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_BRIGHTNESS               "faceattr.condition.brightness"              // Parameter defining reliability condition and dependencies for facial brightness
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_CONTRAST                 "faceattr.condition.contrast"                // Parameter defining reliability condition and dependencies for facial contrast
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_UNIQUE_INTENSITY_LEVELS  "faceattr.condition.unique_intensity_level"  // Parameter defining reliability condition and dependencies for facial unique intensity levels
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SHADOW                   "faceattr.condition.shadow"                  // Parameter defining reliability condition and dependencies for facial shadow
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_NOSE_SHADOW              "faceattr.condition.nose_shadow"             // Parameter defining reliability condition and dependencies for facial sharp shadows
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SPECULARITY              "faceattr.condition.specularity"             // Parameter defining reliability condition and dependencies for facial specularity
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_GAZE                 "faceattr.condition.eye_gaze"                // Parameter defining reliability condition and dependencies for eye gaze
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_STATUS_R             "faceattr.condition.eye_status_r"            // Parameter defining reliability condition and dependencies for right eye statue
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_STATUS_L             "faceattr.condition.eye_status_l"            // Parameter defining reliability condition and dependencies for left eye status  
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_GLASS_STATUS             "faceattr.condition.glass_status"            // Parameter defining reliability condition and dependencies for glass status 
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_HEAVY_FRAME              "faceattr.condition.heavy_frame"             // Parameter defining reliability condition and dependencies for heavy frame  
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_MOUTH_STATUS             "faceattr.condition.mouth_status"            // Parameter defining reliability condition and dependencies for mouth status   
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_BACKGROUND_UNIFORMITY    "faceattr.condition.background_uniformity"   // Parameter defining reliability condition and dependencies for background uniformity   
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_AGE                      "faceattr.condition.age"                     // Parameter defining reliability dependencies for person age estimation
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_RED_EYE_R                "faceattr.condition.red_eye_r"               // Parameter defining reliability condition and dependencies for red-eye effect on right eye
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_RED_EYE_L                "faceattr.condition.red_eye_l"               // Parameter defining reliability condition and dependencies for red-eye effect on left eye
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_ROLL                     "faceattr.condition.roll"                    // Parameter defining reliability condition and dependencies for head orientation - roll 
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_YAW                      "faceattr.condition.yaw"                     // Parameter defining reliability condition and dependencies for head orientation - yaw 
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_PITCH                    "faceattr.condition.pitch"                   // Parameter defining reliability condition and dependencies for head orientation - pitch
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_ROLL_ANGLE               "faceattr.condition.roll_angle"              // Parameter defining reliability condition and dependencies for angle rotation of head towards camera referrence frame around Z-axis as per DIN9300
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_PITCH_ANGLE              "faceattr.condition.pitch_angle"             // Parameter defining reliability condition and dependencies for angle rotation of head towards camera referrence frame around X-axis as per DIN9300
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_YAW_ANGLE                "faceattr.condition.yaw_angle"               // Parameter defining reliability condition and dependencies for angle rotation of head towards camera referrence frame around Y-axis as per DIN9300
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_GENDER                   "faceattr.condition.gender"                  // Parameter defining reliability dependencies for gender estimation 
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SEGMENTATION_MASK        "faceattr.condition.segmentation_mask"       // Parameter defining reliability dependencies for segmentation mask estimation
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_CROP                     "faceattr.condition.crop"                    // Parameter defining reliability dependencies for face cropping rectangle estimation
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_TEMPLATE                 "faceattr.condition.template"                // Parameter defining reliability dependencies for recognition template creation
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_DISTANCE             "faceattr.condition.eye_distance"            // Parameter defining reliability dependencies for eye distance estimation
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_FACE_CONFIDENCE          "faceattr.condition.face_confidence"         // Parameter defining reliability dependencies for face detection
#define IFACE_PARAMETER_FACE_ATTRIBUTE_COND_FACE_SIZE                "faceattr.condition.face_size"               // Parameter defining reliability dependencies for face size estimation

//%<InnoDoc id=parameters_object_processing_desc>
//% Parameters specifying behavior of object processing API functions. They are stored within object handler entity.
//%</InnoDoc>

#define IFACE_PARAMETER_TRACK_MIN_FACE_SIZE                "track.fd.min_face_size"                 // Parameter defining minimal face size of faces detected in discovery frames.
                                                                                                    // <p><i>Value type</i>: Integer, Read-Write
#define IFACE_PARAMETER_TRACK_MAX_FACE_SIZE                "track.fd.max_face_size"                 // Parameter defining maximal face size of faces detected in discovery frames.
                                                                                                    // <p><i>Value type</i>: Integer, Read-Write
#define IFACE_PARAMETER_TRACK_FACE_DISCOVERY_FREQUENCE_MS  "track.fd.discovery_frequence_ms"        // Parameter defining how often often discovery (full frame face detection) frames appear (in milliseconds).
                                                                                                    // This parameter has influence on tracking performance - the more often discovery frames appears the more
                                                                                                    // the slower but more accurate is the tracking.
                                                                                                    // <p><i>Value type</i>: Integer, Read-Write
#define IFACE_PARAMETER_TRACK_DEEP_TRACK                   "track.deep_track"                       // Parameter defining whether face entity is obtainable from tracked object in every video frame ('true') 
                                                                                                    // or not ('false'). Please note that both eyes must be visible (trackable) if deep tracking 
                                                                                                    // should work. This parameter has influence on tracking performance - if set to 'false' then tracking is faster.
                                                                                                    // <p><i>Value type</i>: Boolean, Read-Write
#define IFACE_PARAMETER_TRACK_MOTION_OPTIMIZATION           "track.motion_optimization"             // Parameter defining how video motion detection in video influences object (face) detection in object tracking. 
                                                                                                    // Motion in video can define areas where objects move and object detection can be performed only within these areas.
                                                                                                    // This parameter has influence on tracking performance.
                                                                                                    // <p><i>Value type</i>: String, Read-Write
#define IFACE_PARAMETER_TRACK_SPEED_ACCURACY_MODE           "track.speed_accuracy_mode"             // Parameter defining face tracking accuracy mode, which is a trade-off between speed and accuracy.
                                                                                                    // <p><i>Value type</i>: String, Read-Write
#define IFACE_PARAMETER_TRACK_TRACKING_MODE                 "track.tracking_mode"                   // Parameter defining the tracking mode for switching between the use-cases of the tracking algorithm, 
                                                                                                    // affecting the behavior of the related API functions.
                                                                                                    // <p><i>Value type</i>: String, Read-Write
#define IFACE_PARAMETER_TRACK_MIN_DOT_POSITION_COUNT        "track.min_liveness_dot_positions"      // Parameter defining the minimum number of valid dot positions needed for a dot-based liveness evaluation.
                                                                                                    // <p><i>Value type</i>: Integer over the interval [4;7], Read-Write

//%<InnoDoc id=parameters_object_counting_desc>
//% Parameters specifying behavior of object counting API function. They are stored within object handler entity.
//%</InnoDoc>
#define IFACE_PARAMETER_COUNT_CONFIDENCE_THRESHOLD          "oc.face_confidence_threshold"          // Parameter defining threshold value for face confidence. Objects with lesser value are ignored (not counted).
                                                                                                    // <p><i>Value type</i>: Integer, Read-Write
#define IFACE_PARAMETER_COUNT_REDETECT_TIME_DELTA           "oc.time_delta"                         // Parameter defining the maximum time difference (in milliseconds) between the disappearance of trajectory A and 
                                                                                                    // the appearance of trajectory B, for A and B to be considered as disjoint trajectories of the same object - i.e. represents
                                                                                                    // a trade-off between speed and accuracy regarding unique object estimation.
                                                                                                    // <p><i>Value type</i>: Integer, Read-Write
#define IFACE_PARAMETER_COUNT_MATCH_THRESHOLD               "oc.face_match_threshold"               // Parameter defining matching confidence (similarity) threshold for trajectory merging based on face template.
                                                                                                    // <p><i>Value type</i>: Integer, Read-Write
#define IFACE_PARAMETER_COUNT_TEMPLATE_MERGE                "oc.template_merge"                     // Parameter defining whether the object counting algorithm can use trajectory merging based on face template.
                                                                                                    // <p><i>Value type</i>: Boolean, Read-Write
#define IFACE_PARAMETER_COUNT_REQUIRE_MOVEMENT              "oc.require_movement"                   // Parameter defining whether the object counting algorithm should consider stationary objects as a valid target to count.
                                                                                                    // <p><i>Value type</i>: Boolean, Read-Write

#endif
