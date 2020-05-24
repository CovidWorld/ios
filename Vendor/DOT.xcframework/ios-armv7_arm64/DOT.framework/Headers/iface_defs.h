// This header file contains declarations of IFace SDK constants.
#ifndef _IFACE_DEFS_H
#define _IFACE_DEFS_H


// Enum IDs for data structures (entities) used by IFace
typedef enum {
    IFACE_ENTITY_TYPE_FACE_HANDLER = 0,         // face handler
    IFACE_ENTITY_TYPE_FACE = 1,                 // face data
    IFACE_ENTITY_TYPE_PEDESTRIAN_HANDLER = 2,   // pedestrian handler
    IFACE_ENTITY_TYPE_PEDESTRIAN = 3,           // pedestrian data
    IFACE_ENTITY_TYPE_OBJECT_HANDLER = 4,       // object handler
    IFACE_ENTITY_TYPE_OBJECT = 5,               // object data
} IFACE_EntityType;

// Each facial feature has its own ID.
// Names of the features are based on anatomical position of the feature on a face (not position as seen on image)
// E.g. right eye is the persons right eye.
typedef enum
{
    IFACE_FACE_FEATURE_ID_UNKNOWN = -1,                    // unknown facial feature

    IFACE_FACE_FEATURE_ID_RIGHT_EYE_OUTER_CORNER = 0,	   // right eye outer corner
    IFACE_FACE_FEATURE_ID_RIGHT_EYE_CENTRE = 1,		       // right eye center
    IFACE_FACE_FEATURE_ID_RIGHT_EYE_INNER_CORNER = 2,	   // right eye inner corner

    IFACE_FACE_FEATURE_ID_LEFT_EYE_INNER_CORNER = 3,	   // left eye inner corner
    IFACE_FACE_FEATURE_ID_LEFT_EYE_CENTRE = 4,		       // left eye center
    IFACE_FACE_FEATURE_ID_LEFT_EYE_OUTER_CORNER = 5,	   // left eye outer corner

    IFACE_FACE_FEATURE_ID_NOSE_ROOT = 6,                   // nose root
    IFACE_FACE_FEATURE_ID_NOSE_RIGHT_BOTTOM = 7,           // nose right bottom
    IFACE_FACE_FEATURE_ID_NOSE_TIP = 8,                    // nose tip
    IFACE_FACE_FEATURE_ID_NOSE_LEFT_BOTTOM = 9,            // nose left bottom
    IFACE_FACE_FEATURE_ID_NOSE_BOTTOM = 10,                // nose bottom

    IFACE_FACE_FEATURE_ID_MOUTH_RIGHT_CORNER = 11,	       // right corner of mouth
    IFACE_FACE_FEATURE_ID_MOUTH_CENTER = 12,               // center of the mouth
    IFACE_FACE_FEATURE_ID_MOUTH_LEFT_CORNER = 13,	       // left corner of mouth
    IFACE_FACE_FEATURE_ID_MOUTH_UPPER_EDGE = 14,	       // center point on outer edge of upper lip
    IFACE_FACE_FEATURE_ID_MOUTH_LOWER_EDGE = 15,	       // center point on outer edge of lower lip

    IFACE_FACE_FEATURE_ID_RIGHT_EYEBROW_OUTER_END = 16,    // outer end of right eye brow
    IFACE_FACE_FEATURE_ID_RIGHT_EYEBROW_INNER_END = 17,    // inner end of right eye brow
    IFACE_FACE_FEATURE_ID_LEFT_EYEBROW_INNER_END = 18,     // inner end of left eye brow
    IFACE_FACE_FEATURE_ID_LEFT_EYEBROW_OUTER_END = 19,     // outer end of left eye brow

    IFACE_FACE_FEATURE_ID_FACE_RIGHT_EDGE = 20,            // right edge of face
    IFACE_FACE_FEATURE_ID_FACE_CHIN_TIP = 21,              // tip of chin
    IFACE_FACE_FEATURE_ID_FACE_LEFT_EDGE = 22,             // left edge of face
} IFACE_FaceFeatureId;

// \Face can be cropped using one of listed methods
typedef enum
{
    IFACE_FACE_CROP_METHOD_TOKEN_FRONTAL = 0,           // Token Frontal Image cropping method defined in ISO/IEC 19794-5 standard
    IFACE_FACE_CROP_METHOD_FULL_FRONTAL = 1,            // Full Frontal Image cropping method defined in ISO/IEC 19794-5 standard
    IFACE_FACE_CROP_METHOD_FULL_FRONTAL_EXTENDED = 2,   // Full Frontal Image cropping method defined in ISO/IEC 19794-5 standard with canvas
                                                        // size center-enlarged by factor specified in parameter
                                                        // IFACE_PARAMETER_FACE_CROP_FULLFRONTAL_EXTENDED_SCALE in each direction.
    IFACE_FACE_CROP_METHOD_TOKEN_NOT_FRONTAL = 3,       // Image cropping method similar to `Token` but works quite well even on non-frontal images
    IFACE_FACE_CROP_METHOD_TOKEN_FRONTAL_EXTENDED = 4,  // Token Frontal Image cropping method defined in ISO/IEC 19794-5 standard with canvas
                                                        // size center-enlarged by factor specified in parameter
                                                        // IFACE_PARAMETER_FACE_CROP_TOKEN_FRONTAL_EXTENDED_SCALE in each direction.
} IFACE_FaceCropMethod;


// Image can be save to memory with listed formats
typedef enum
{
    IFACE_IMAGE_SAVE_TYPE_BMP = 0,              // Windows bitmap
    IFACE_IMAGE_SAVE_TYPE_JPG = 1,              // JPEG file
    IFACE_IMAGE_SAVE_TYPE_PNG = 2,              // Portable Network Graphics
    IFACE_IMAGE_SAVE_TYPE_TIFF = 3              // TIFF file
} IFACE_ImageSaveType;


// Resulting Segmentation image types
typedef enum
{
    IFACE_SEGMENTATION_IMAGE_TYPE_MASK = 0,            // Only segmentation mask (one channel image).
    IFACE_SEGMENTATION_IMAGE_TYPE_MASKED = 1,          // Segmentation mask applied to image. Masked parts (background) are filled with color
                                                      // specified in IFACE_PARAMETER_BACKGROUND_COLOR (three channel image).
    IFACE_SEGMENTATION_IMAGE_TYPE_MASKED_ALPHA = 2     // Segmentation mask applied to image. Masked parts (background) are transparent (four channel image).
} IFACE_SegmentationImageType;


// IFace can be used with logging turned on by IFACE_SetLogger function. Various logging levels can be set.
typedef enum
{
    IFACE_LOGGER_SEVERITY_LEVEL_DEBUG = -1,         // Messages with levels FATAL, ERROR, WARNING, INFO are logged as well as API entries and exits
    IFACE_LOGGER_SEVERITY_LEVEL_INFO = 0,           // Messages with levels FATAL, ERROR, WARNING, INFO are logged
    IFACE_LOGGER_SEVERITY_LEVEL_WARNING = 1,        // Messages with levels FATAL, ERROR, WARNING are logged
    IFACE_LOGGER_SEVERITY_LEVEL_ERROR = 2,          // Messages with levels FATAL, ERROR are logged
    IFACE_LOGGER_SEVERITY_LEVEL_FATAL = 3,          // Only messages with levels FATAL are logged
} IFACE_LoggerSeverityLevel;

// Possible results of face attribute reliability range evaluation. Reliability range evaluation tells whether
// face attribute value is below, in, or above reliability range defined in face attribute condition.
// Reliability range evaluation is not dependent on face attribute dependencies evaluation.
// However the final result of reliability evaluation (ICAO compliance) depends on reliability range
// evaluation as well as on feature attribute dependencies evaluation.
typedef enum
{
    IFACE_FACE_ATTRIBUTE_RANGE_STATUS_TOO_LOW = -1,      // \Face attribute value below reliability range
    IFACE_FACE_ATTRIBUTE_RANGE_STATUS_IN_RANGE = 0,      // \Face attribute value in reliability range
    IFACE_FACE_ATTRIBUTE_RANGE_STATUS_TOO_HIGH = 1,      // \Face attribute value above reliability range
} IFACE_FaceAttributeRangeStatus;

// Possible results of face attribute dependencies evaluation. Each face attribute can have its own
// dependencies (it is dependent on some other face attributes). Once these dependencies are fulfilled
// then the result of the face attribute evaluation can be taken as valid.
typedef enum
{
    IFACE_FACE_ATTRIBUTE_DEPENDENCIES_STATUS_NOT_OK = 0,      // \Face attribute dependencies are not fulfilled, so
                                                              // value of the face attribute can't be trusted.
    IFACE_FACE_ATTRIBUTE_DEPENDENCIES_STATUS_OK = 1           // face attribute dependencies are fulfilled, so
                                                              // value of the face attribute can be trusted
} IFACE_FaceAttributeDependenciesStatus;

// \Face attribute IDs for various face processing operations - ICAO features (e.g. mouth status, eyes_status),
// face recognition (age, gender, verification template).
// Functions <c>IFACE_GetFaceAttribute</c>, <c>IFACE_GetFaceAttributeRaw</c>, <c>IFACE_GetFaceAttributeDependenciesStatus</c>
// <c>IFACE_GetFaceAttributeRangeStatus</c> and face attribute conditions parameters are related to evaluation of these features.
typedef enum
{
    IFACE_FACE_ATTRIBUTE_ID_SHARPNESS = 0,                  // \Face attribute for evaluating whether an area of face image is not blurred.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Sharpness values are from range <-10000,10000>.  Values near -10000 indicates 'very blurred', values near 10000 indicates 'very sharp'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_BRIGHTNESS = 1,                 // \Face attribute for evaluating whether an area of face is correctly exposed.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Brightness values are from range <-10000,10000>. Values near -10000 indicates 'too dark', values near 10000 indicates 'too light', values around 0 indicates OK.
                                                            // The decision thresholds are around -5000 and 5000.
    IFACE_FACE_ATTRIBUTE_ID_CONTRAST = 2,                   // \Face attribute for evaluating whether an area of face is contrast enough.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Contrast values are from range <-10000,10000>. Values near -10000 indicates 'very low contrast', values near 10000 indicates 'very high contrast', values around 0 indicates OK.
                                                            // The decision thresholds are around -5000 and 5000.
    IFACE_FACE_ATTRIBUTE_ID_UNIQUE_INTENSITY_LEVELS = 3,    // \Face attribute for evaluating whether an area of face has appropriate number of unique intensity levels.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Unique intensity levels values are from range <-10000,10000>. Values near -10000 indicates 'very few unique intensity levels', values near 10000 indicates 'enough unique intensity levels'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_SHADOW = 4,                     // \Face attribute for evaluating whether an area of face is not overshadowed.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Shadow values are from range <-10000,10000>. Values near -10000 indicates 'very strong global shadows present', values near 10000 indicates 'no global shadows present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_NOSE_SHADOW = 5,                // \Face attribute for evaluating whether eyes or a nose don't cast sharp shadows.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Nose shadow values are from range <-10000,10000> Values near -10000 indicates 'very strong local (eyes/nose) shadows present', values near 10000 indicates 'no local shadows present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_SPECULARITY = 6,                // \Face attribute for evaluating whether spotlights aren't present on face.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Specularity values are from range <-10000,10000> Values near -10000 indicates 'very strong specularity present', values near 10000 indicates 'no specularity present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_EYE_GAZE = 7,                   // \Face attribute for evaluating whether a gaze-direction is frontal.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Eye gaze values are from range <-10000,10000>. Values near -10000 indicates 'sideway ahead eyes gaze', values near 10000 indicates 'straight ahead eyes gaze'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_EYE_STATUS_R = 8,               // \Face attribute for evaluating right eye status.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Right eye values are from range <-10000,10000>. Values near -10000 indicates 'closed, narrowed or bulged eye', values near 10000 indicates 'normally opened eye'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_EYE_STATUS_L = 9,               // \Face attribute for evaluating left eye status.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Left eye values are from range <-10000,10000>. Values near -10000 indicates 'closed, narrowed or bulged eye', values near 10000 indicates 'normally opened eye'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_GLASS_STATUS = 10,              // \Face attribute for evaluating glasses presence.
                                                            // Glasses values are from range <-10000,10000>. Values near -10000 indicates 'no glasses present', values near 10000 indicates 'glasses present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_HEAVY_FRAME = 11,               // \Face attribute for evaluating whether glasses with heavy frames are not present.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Heavy frame glasses values are from range <-10000,10000>. Values near -10000 indicates 'no heavy frame glasses present', values near 10000 indicates 'heavy frame glasses present'. The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_MOUTH_STATUS = 12,              // \Face attribute for evaluating mouth status.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Mouth status values are from range <-10000,10000>. Values near -10000 indicates 'open mouth, smile showing teeth or round lips present', values near 10000 indicates 'mouth with no expression'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_BACKGROUND_UNIFORMITY = 13,     // \Face attribute for evaluating whether background is uniform.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Background uniformity values are from range <-10000,10000>. Values near -10000 indicates 'very un-uniform background present', values near 10000 indicates 'uniform background present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_AGE = 14,                       // \Face attribute for evaluating age of subject using the face.
    IFACE_FACE_ATTRIBUTE_ID_RED_EYE_R = 15,                 // \Face attribute for evaluating whether red-eye effect is not present on right eye.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Right red-eye effect values are from range <-10000,10000>. Values near -10000 indicates 'no red-eye effect present', values near 10000 indicates 'red-eye effect present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_RED_EYE_L = 16,                 // \Face attribute for evaluating whether red-eye effect is not present on left eye.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Left red-eye effect values are from range <-10000,10000>. Values near -10000 indicates 'no red-eye effect present', values near 10000 indicates 'red-eye effect present'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_ROLL = 17,                      // \Face attribute for evaluating whether head roll is in range.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Roll rotation values are from range <-10000,10000>. Values near -10000 indicates 'too left rotated', values near 10000 indicates 'too right rotated', values around 0 indicates OK.
                                                            // The decision thresholds are around -5000 and 5000.
    IFACE_FACE_ATTRIBUTE_ID_YAW = 18,                       // \Face attribute for evaluating whether head yaw is in range.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Yaw rotation values are from range <-10000,10000> Values near -10000 indicates 'too left rotated', values near 10000 indicates 'too right rotated', values around 0 indicates OK.
                                                            // The decision thresholds are around -5000 and 5000.
    IFACE_FACE_ATTRIBUTE_ID_PITCH = 19,                     // \Face attribute for evaluating whether head pitch is in range.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // Pitch rotation values are from range <-10000,10000> Values near -10000 indicates 'pitch too down', values near 10000 indicates 'pitch too up', values around 0 indicates OK.
                                                            // The decision thresholds are around -5000 and 5000.
    IFACE_FACE_ATTRIBUTE_ID_GENDER = 20,                    // \Face attribute for evaluating gender of subject.
                                                            // Gender values are from range <-10000, 10000>. Values near -10000 indicates 'male', values near 10000 indicates 'female'.
                                                            // The decision threshold is around 0.
    IFACE_FACE_ATTRIBUTE_ID_SEGMENTATION_MASK = 21,         // \Face attribute for evaluating whether correct image head-shoulder segmentation can be done.

    IFACE_FACE_ATTRIBUTE_ID_CROP = 22,                      // \Face attribute for evaluating whether correct face image cropping can be done.

    IFACE_FACE_ATTRIBUTE_ID_TEMPLATE = 23,                  // \Face attribute for evaluating whether face template can be extracted.

    IFACE_FACE_ATTRIBUTE_ID_EYE_DISTANCE = 24,              // \Face attribute for evaluating distance between eyes in pixels.
                                                            // The attribute can be taken as an ICAO feature.
    IFACE_FACE_ATTRIBUTE_ID_FACE_CONFIDENCE = 25,           // \Face attribute for evaluating confidence score of the face related to face detection.
                                                            // The attribute can be taken as an ICAO feature.
                                                            // \Face confidence values are from range <0,10000>. The higher the value of the attribute the better quality of the face.
                                                            // The decision thresholds are around 600, but it depends on the face image quality / camera angle etc.

    IFACE_FACE_ATTRIBUTE_ID_FACE_VERIFICATION_CONFIDENCE = 26,   // \Face attribute for evaluating suitability of face for matching, so called template verification confidence.

    IFACE_FACE_ATTRIBUTE_ID_FACE_RELATIVE_AREA = 27,             // Area of face relative to image size
    IFACE_FACE_ATTRIBUTE_ID_FACE_RELATIVE_AREA_IN_IMAGE = 28,    // Area of face visible in image relative to total area of face. This value implies the percentage of face area outside the image.

    IFACE_FACE_ATTRIBUTE_ID_ROLL_ANGLE = 29,                // \Face attribute representing angle rotation of head towards camera referrence frame around Z-axis as per DIN9300

    IFACE_FACE_ATTRIBUTE_ID_PITCH_ANGLE = 30,               // \Face attribute representing angle rotation of head towards camera referrence frame around X-axis as per DIN9300

    IFACE_FACE_ATTRIBUTE_ID_YAW_ANGLE = 31,                 // \Face attribute representing angle rotation of head towards camera referrence frame around Y-axis as per DIN9300

    IFACE_FACE_ATTRIBUTE_ID_FACE_SIZE = 32,                 // \Face attribute representing face size - the maximum of eye distance and eye-mouth distance.

    IFACE_FACE_ATTRIBUTE_ID_LAST_ITEM = 33                  // Auxiliary attribute defining last item of the IFACE_FaceAttributeId enum
} IFACE_FaceAttributeId;


// Possible statuses of the object during tracking
typedef enum
{
    IFACE_TRACKED_OBJECT_STATE_CLEAN = 0,                       // Object doesn't contain any tracking info
    IFACE_TRACKED_OBJECT_STATE_TRACKED = 1,                     // Object is currently successfully tracked
    IFACE_TRACKED_OBJECT_STATE_SUSPEND = 2,                     // Object tracking is currently suspended (object has been lost), but it
                                                                // can be tracked again in future frames if it appears again
    IFACE_TRACKED_OBJECT_STATE_COVERED = 3,                     // Object is currently covered by another tracked object, but it
                                                                // can be tracked again in future frames if it appears again
    IFACE_TRACKED_OBJECT_STATE_LOST = 4                         // Object is lost from the scene and the tracking is stopped
} IFACE_TrackedObjectState;


// Possible types of the tracked object
typedef enum
{
    IFACE_TRACKED_OBJECT_TYPE_FACE = 0,                   // Tracked object initialized by face detection
    IFACE_TRACKED_OBJECT_TYPE_GENERAL_RECT = 1            // Tracked object initialized by general rectangle position and size
} IFace_TrackedObjectType;


// Possible types of face, that can be obtained from tracked object
typedef enum
{
    IFACE_TRACKED_OBJECT_FACE_TYPE_LAST = 0,                  // \Face from the last frame. Parameter <c>IFACE_PARAMETER_TRACK_DEEP_TRACK</c> must be set to 'true' if this face type has to be obtained.
    IFACE_TRACKED_OBJECT_FACE_TYPE_LAST_DISCOVERY = 1,        // \Face from the last discovery frame.
    IFACE_TRACKED_OBJECT_FACE_TYPE_BEST_DISCOVERY = 2         // \Face with the highest face confidence from all discovery frames processed during object tracking.
} IFACE_TrackedObjectFaceType;


// Possible states of face liveness check
typedef enum
{
    IFACE_LIVENESS_STATE_NOT_STARTED = 0,                     // Liveness data collection hasn't started yet.
    IFACE_LIVENESS_STATE_FINISHED_NOT_ENOUGH = 1,             // Liveness data collection has been interrupted before enough data was collected.
    IFACE_LIVENESS_STATE_FINISHED_ENOUGH = 2,                 // Liveness data collection has been interrupted but enough data was collected.
    IFACE_LIVENESS_STATE_INPROGRESS_NOT_ENOUGH = 3,           // Liveness data collection is in progress, but there is still not enough data collected for liveness score evaluation.
    IFACE_LIVENESS_STATE_INPROGRESS_ENOUGH = 4,               // Liveness data collection is in progress, there is enough data collected for liveness score evaluation and the collection continues.
} IFACE_LivenessState;


//%<InnoDoc id=constants_desc>
//% In addition to enumerated values defined in IFace SDK enumerated data types, IFace SDK also
//% contains constants and error codes.
//%</InnoDoc>
#define IFACE_FACE_ATTRIBUTE_COUNT     IFACE_FACE_ATTRIBUTE_ID_LAST_ITEM   // Count of face attributes evaluated on face entity
#define IFACE_GLOBAL_PARAMETERS        NULL                                // Value used for entity parameter in <c>IFACE_SetParam</c>, <c>IFACE_GetParamSize</c>
                                                                           // and <c>IFACE_GetParam</c> functions calls when global parameters are set.
                                                                           // This can be done only before calling <c>IFACE_Init.</c>

//%<InnoDoc id=iface_feature_states_desc>
//% Facial features retrieved by API function <c>IFACE_GetFaceFeatures</c> have confidence score if they are detectable.
//% If they are not detectable then they can have various states.
//%</InnoDoc>

//%<InnoTable id=iface_feature_states>
#define IFACE_FACE_FEATURE_STATE_DETECTABLE_NO_CONFIDENCE -1             // Facial features is detectable but with no confidence assigned
#define IFACE_FACE_FEATURE_STATE_UNDETECTABLE             -2             // Facial features is undetectable due to various reasons

//%</InnoTable>

//%<InnoDoc id=iface_facedet_speed_accuracy>
//% IFace has different face detection modes. Using of different modes can adjust trade-off between speed and accuracy of face detection.
//% \Face detection accuracy has two meaning:
//%
//% 1) ratio between false accepted faces and false rejected faces
//%
//% 2) precision of facial features detection
//%
//% The value of parameter <c>IFACE_PARAMETER_FACEDET_SPEED_ACCURACY_MODE</c> determines which mode is used.
//%</InnoDoc>

//%<InnoTable id=iface_facedet_speed_accuracy_modes>
#define IFACE_FACEDET_SPEED_ACCURACY_MODE_ACCURATE  "accurate"    // Neural network face detector and facial features detector with very high accuracy.
                                                                  // It is slower than <c>balanced</c> mode. This mode can be fully GPU accelerated.

#define IFACE_FACEDET_SPEED_ACCURACY_MODE_BALANCED  "balanced"    // Neural network face detector and facial features detector with good accuracy.
                                                                  // It is slower than <c>fast</c> mode. This mode can be fully GPU accelerated.

#define IFACE_FACEDET_SPEED_ACCURACY_MODE_FAST      "fast"        // The fastest face detector in combination with the fastest
                                                                  // face validators and facial features detectors are used when <i>fast</i>
                                                                  // mode is used. Some faces that are partially occluded faces or
                                                                  // faces with sunglasses may be missed. However the speed performance
                                                                  // of the face detection is much better as when other modes are used.
                                                                  // This mode can be only partially GPU accelerated.

#define IFACE_FACEDET_SPEED_ACCURACY_MODE_FAST_E1   "fast_e1"     // Experimental version of the <i>fast</i> mode, offering even better performance
                                                                  // regarding speed at the expense of accuracy. When this mode is used then only eyes position (IFACE_FACE_FEATURE_ID_RIGHT_EYE_CENTRE,
                                                                  // IFACE_FACE_FEATURE_ID_LEFT_EYE_CENTRE) can be retrieved as well as facial attributes related to eyes (e.g. mouth status, nose shadow,
                                                                  // or crop attributes are not accessible).
                                                                  // Recommended for devices with limited computational power.

#define IFACE_FACEDET_SPEED_ACCURACY_MODE_ACCURATE_SERVER "accurate_server" // Accurate server mode (available only in server edition) with highest accuracy available in IFace.
                                                                            // Very robust neural network based face detector - partially occluded, blury, profile, rotated
                                                                            // faces or faces with sunglasses are detected. Speed of this face detection on CPU is the slowest comparing to other
                                                                            // modes. This mode can be fully GPU accelerated.

//%</InnoTable>

//%<InnoDoc id=iface_track_speed_accuracy>
//% IFace has different face tracking modes. Using of different modes can adjust trade-off between speed and accuracy of face tracking.
//% The value of parameter <c>IFACE_PARAMETER_FACETRACK_SPPED_ACCURACY_MODE</c> determines which mode is used.
//%</InnoDoc>

//%<InnoTable id=iface_facetrack_speed_accuracy_modes>
#define IFACE_TRACK_SPEED_ACCURACY_MODE_ACCURATE  "accurate"    // The most precise face tracking method
                                                                // However the performance of the face tracking is not as good as when <c>fast</c> mode is used.

#define IFACE_TRACK_SPEED_ACCURACY_MODE_BALANCED  "balanced"    // The performance and speed is somewhere between <c>fast</c> and <c>accurate</c>


#define IFACE_TRACK_SPEED_ACCURACY_MODE_FAST      "fast"        // The fastest face tracking methods are used when this mode is selected

//%</InnoTable>

//%<InnoDoc id=iface_faceverif_speed_accuracy_modes_desc>
//% IFace has different face verification modes. Using of different modes can adjust trade-off between face template creation speed and face template quality.
//% \Face templates of higher quality give better results when used in <c>IFACE_MatchTemplate</c> function.
//% The value of parameter <c>IFACE_PARAMETER_FACETMPLEXT_SPEED_ACCURACY_MODE</c> determines which mode is used.
//% Templates created with different modes are not compatible and therefore they cannot be used together <c>in IFACE_MatchTemplate</c>.
//% Compatibility of templates can be evaluated using <c>IFACE_GetTemplateInfo</c>, where retrieved teplates versions can be compared.
//%</InnoDoc>

//%<InnoTable id=iface_faceverif_speed_accuracy_modes>
#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_ACCURATE  "accurate"    // \Face templates suitable for verification/identification of very high accuracy are created when <i>accurate</i> mode is used.
                                                                      // However the performance of the face template creation is not as good as when <c>balanced</c> or <c>fast</c> mode is used.
                                                                    
#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_BALANCED  "balanced"    // \Face templates suitable for verification/identification of high accuracy are created when <i>balanced</i> mode is used.
                                                                      // The performance of the face template creation is somewhere in between of <c>accurate</c> and <c>fast</c> modes.

#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_FAST      "fast"        // \Face templates suitable for verification of fairly good accuracy are created when <i>fast</i> mode is used.
                                                                      // The performance of face template creation is very fast. Suitable for mobile/embedded devices.

#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_ACCURATE_SERVER  "accurate_server"  // \Face templates of even better quality then templates generated by <i>accurate</i> mode. Mode used in FRVT benchmarks.
                                                                                  // However the performance of the face template creation is not as good as when <c>accurate</c> mode is used.

//%</InnoTable>

//%<InnoDoc id=iface_agegender_speed_accuracy_modes_desc>
//% IFace has different modes of age and gender evaluation. Using of different modes can adjust trade-off between age end gender evaluation speed
//% and precision of the age and gender predictions.
//% The value of parameter <c>IFACE_PARAMETER_AGEGENDER_SPEED_ACCURACY_MODE</c> determines which mode is used.
//%</InnoDoc>

//%<InnoTable id=iface_agegender_speed_accuracy_modes>
#define IFACE_AGEGENDER_SPEED_ACCURACY_MODE_ACCURATE  "accurate"    // Precision of age and gender predictions is the best.
                                                                    // However the performance of the age and gender evaluation is not as good as when <c>fast</c> mode is used.
#define IFACE_AGEGENDER_SPEED_ACCURACY_MODE_FAST      "fast"        // The evaluation of the age and gender is the fastest.
                                                                    // However precision of these predictions is not as good as when <c>accurate</c> mode is used.

//%</InnoTable>

//%<InnoDoc id=iface_multithreading>
//% IFace SDK is thread safe, which means that any API function can be called simultaneously from multiple threads created by user.
//% Depending on count of CPU cores and IFace multi-threading settings different levels of parallelization can be achieved with IFace SDK.
//% IFace API functions allow parallel processing in these ways:
//%
//% 1) \Face handler entity functions - functions using face handler, such as <c>IFACE_DetectFaces</c>, <c>IFACE_MatchTemplate</c> can
//%                                     be called in parallel on different face handler entities.
//%
//% 2) \Face entity functions - functions related to face entities, such as <c>IFACE_GetFaceAttribute</c> can be called in
//%                             parallel on different face entities.
//%
//% 3) \Object handler entity functions - functions using object handler, such as <c>IFACE_TrackObjects</c> can
//%                                      be called in parallel on different face handler entities.
//%
//% 4) \Object entity functions - functions related to object entities, such as <c>IFACE_GetObjectState</c> or <c>IFACE_GetObjectTrajectory</c> can
//%                               be called in parallel on different face entities.
//%
//% Moreover, parallel processing is used within face detection, where parallel threads search different parts of input image and
//% validate candidate faces.
//%
//% Parameters listed in <link macros_parameters_global_multithreading, Threading parameters> topic are related to IFace multi-threading settings.
//%
//% The value of parameter <c>IFACE_PARAMETER_GLOBAL_THREAD_MANAGEMENT_MODE</c> determines which IFace multi-threading mode is used.
//% Using of various multi-threading modes can adjust the trade-off between level of parallelism and memory consumption.
//%</InnoDoc>

//%<InnoTable id=iface_multithreading_modes>
#define IFACE_GLOBAL_THREAD_MANAGEMENT_MODE_SINGLE       "single"       // Parallel processing is disabled and just single thread is used inside IFace SDK even when it is called in parallel with more threads.
                                                                        // Defined number of threads <c>IFACE_PARAMETER_GLOBAL_THREAD_NUM</c> is ignored.
                                                                        // This mode is the least memory consumptive mode.

#define IFACE_GLOBAL_THREAD_MANAGEMENT_MODE_MAX_PARALLEL "max_parallel" // The highest level of parallelism can be achieved when this mode is set.
                                                                        // Defined number of threads <c>IFACE_PARAMETER_GLOBAL_THREAD_NUM</c> can be used in parallel within each entity.
                                                                        // The performance of this mode should be the highest however the memory requirements are the highest as well.
                                                                        // Due to parallel processing the memory is allocated with each face handler entity.

#define IFACE_GLOBAL_THREAD_MANAGEMENT_MODE_MIN_MEMORY   "min_memory"   // Defined number of threads <c>IFACE_PARAMETER_GLOBAL_THREAD_NUM</c> used in parallel are shared between all face handlers.
                                                                        // However when just one face handler entity is active then it can use <c>IFACE_PARAMETER_GLOBAL_THREAD_NUM</c>
                                                                        // threads in parallel. No memory Due to parallel processing is allocated with each created face handler entity.

//%</InnoTable>

//%<InnoDoc id=iface_matting>
//% IFace can perform head-shoulder background segmentation. The basic segmentation provide just binary mask.
//% Matting refers to the problem of accurate foreground estimation and can improve more accurate segmentation for various hairstyles.
//% The value of parameter <c>IFACE_PARAMETER_SEGMENTATION_MATTING_TYPE</c> determines which matting is used.
//%</InnoDoc>

//%<InnoTable id=iface_matting_modes>
#define IFACE_SEGMENTATION_MATTING_OFF                   "matting_off"       // Defines no matting after head shoulder segmentation to soften mask edges
#define IFACE_SEGMENTATION_MATTING_GLOBAL                "matting_global"    // Global matting is used after head shoulder segmentation to soften mask edges

//%</InnoTable>

//%<InnoDoc id=iface_motion_optimization>
//% During object tracking, object (face) detection can be performed in whole image or just in the areas where motion occurs.
//% Thus, video motion detection is used for tracking optimization. The value of parameter <c>IFACE_PARAMETER_TRACK_MOTION_OPTIMIZATION</c>
//% determines which optimization is used.
//%</InnoDoc>

//%<InnoTable id=iface_track_motion_optimization_modes>
#define IFACE_TRACK_MOTION_OPTIMIZATION_DISABLED                "track.motion_optimization.disabled"              // Motion optimization is disabled
#define IFACE_TRACK_MOTION_OPTIMIZATION_HISTORY_SHORT           "track.motion_optimization.history_short"         // Motion is detected only within very short video history.
#define IFACE_TRACK_MOTION_OPTIMIZATION_HISTORY_LONG_ACCURATE   "track.motion_optimization.history_long.accurate" // Motion is detected within longer video frames history. Bigger rectangular areas around motion
                                                                                                                  // detected regions are used for object detection.
#define IFACE_TRACK_MOTION_OPTIMIZATION_HISTORY_LONG_FAST       "track.motion_optimization.history_long.fast"     // Motion is detected within longer video frames history. Just motion
                                                                                                                  // detected regions are used for object detection.

//%</InnoTable>

//%<InnoDoc id=iface_tracking_mode>
//% The tracking algorithm can be used in multiple scenarios such as general object (faces) tracking or face liveness evaluation.
//% For each scenario has IFace SDK dedicated tracking mode, that has influence to performance and functionality.
//% The value of parameter <c>IFACE_PARAMETER_TRACK_TRACKING_MODE</c> determines which tracking mode is used.
//%</InnoDoc>

//%<InnoTable id=iface_track_tracking_modes>
#define IFACE_TRACK_TRACKING_MODE_OBJECT_TRACKING               "track.tracking_mode.object_tracking"             // Moving objects (faces) are detected and subsequently tracked on a scene.
#define IFACE_TRACK_TRACKING_MODE_LIVENESS_DOT                  "track.tracking_mode.liveness_dot"                // Face liveness detection based on dot (and the related eye) movement.

//%</InnoTable>

//%<InnoDoc id=parameters_default_values_desc>
//% All IFace SDK parameters has their default values.
//%</InnoDoc>

#define IFACE_GLOBAL_THREAD_NUM_DEFAULT                    "1"                                                 // Default maximum count of threads used within one face handler entity - parameter <c>IFACE_PARAMETER_GLOBAL_THREAD_NUM</c>.
#define IFACE_GLOBAL_THREAD_MANAGEMENT_MODE_DEFAULT        IFACE_GLOBAL_THREAD_MANAGEMENT_MODE_MIN_MEMORY      // Default value for threading mode - parameter <c>IFACE_PARAMETER_GLOBAL_THREAD_MANAGEMENT_MODE</c>.
#define IFACE_GLOBAL_MIN_VALID_FACE_SIZE_DEFAULT           "12"                                                // Default value for minimal valid size of face detectable by IFace SDK - parameter <c>IFACE_GLOBAL_MIN_VALID_FACE_SIZE_DEFAULT</c>.
#define IFACE_GLOBAL_MIN_VALID_IMAGE_SIZE_DEFAULT          "15"                                                // Default value for minimal valid size (width or height) of image accepted by IFace SDK - parameter <c>IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE</c>.

#ifndef TINY_IFACE

#define IFACE_FACEDET_SPEED_ACCURACY_MODE_DEFAULT          IFACE_FACEDET_SPEED_ACCURACY_MODE_BALANCED          // Default value for face detection mode - parameter <c>IFACE_PARAMETER_FACEDET_SPEED_ACCURACY_MODE</c>.
#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_DEFAULT      IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_ACCURATE      // Default value for face verification mode - parameter <c>IFACE_PARAMETER_FACETMPLEXT_SPEED_ACCURACY_MODE</c>.
#define IFACE_AGEGENDER_SPEED_ACCURACY_MODE_DEFAULT        IFACE_AGEGENDER_SPEED_ACCURACY_MODE_FAST            // Default value for age and gender mode - parameter <c>IFACE_PARAMETER_AGEGENDER_SPEED_ACCURACY_MODE</c>.

#else

#define IFACE_FACEDET_SPEED_ACCURACY_MODE_DEFAULT          IFACE_FACEDET_SPEED_ACCURACY_MODE_FAST
#ifdef CFG_IFACE_WITH_ACCURATE
#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_DEFAULT        IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_ACCURATE
#else
#define IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_DEFAULT        IFACE_FACETMPLEXT_SPEED_ACCURACY_MODE_FAST
#endif

#endif

#define IFACE_TRACK_SPEED_ACCURACY_MODE_DEFAULT            IFACE_TRACK_SPEED_ACCURACY_MODE_ACCURATE            // Default value for face tracking mode - parameter <c>IFACE_PARAMETER_FACETRACK_SPEED_ACCURACY_MODE</c>.

#define IFACE_FACE_DET_MAX_IMAGE_SIZE_DEFAULT    1200         // Default value for IFACE_PARAMETER_FACE_DET_MAX_IMAGE_SIZE

#define IFACE_BACKGROUND_COLOR_DEFAULT                     "FFFFFF"                                            // Default value for filling background color - parameter <c>IFACE_PARAMETER_BACKGROUND_COLOR</c>.
#define IFACE_FACE_CROP_FULLFRONTAL_EXTENDED_SCALE_DEFAULT "20"                                                // Default value for background area enlargement for IFACE_FACE_CROP_METHOD_FULL_FRONTAL_EXTENDED cropping - parameter <c>IFACE_PARAMETER_FACE_CROP_FULLFRONTAL_EXTENDED_SCALE</c>.
#define IFACE_FACE_CROP_TOKEN_FRONTAL_EXTENDED_SCALE_DEFAULT "20"                                              // Default value for background area enlargement for IFACE_FACE_CROP_METHOD_TOKEN_FRONTAL_EXTENDED cropping - parameter <c>IFACE_PARAMETER_FACE_CROP_TOKEN_FRONTAL_EXTENDED_SCALE</c>.
#define IFACE_SEGMENTATION_MATTING_TYPE_DEFAULT            IFACE_SEGMENTATION_MATTING_OFF                      // Default value for matting after head shoulder segmentation - parameter <c>IFACE_PARAMETER_SEGMENTATION_MATTING_TYPE</c>

#define IFACE_TRACK_MIN_FACE_SIZE_DEFAULT                "18"                        // Default value for minimal face size of faces detected in discovery frames - parameter <c>IFACE_PARAMETER_TRACK_MIN_FACE_SIZE</c>
#define IFACE_TRACK_MAX_FACE_SIZE_DEFAULT                "400"                       // Default value for maximal face size of faces detected in discovery frames - parameter <c>IFACE_PARAMETER_TRACK_MAX_FACE_SIZE</c>
#define IFACE_TRACK_FACE_DISCOVERY_FREQUENCE_MS_DEFAULT  "1000"                      // Default value for how often discovery frames appear (in milliseconds) - parameter <c>IFACE_PARAMETER_TRACK_FACE_DISCOVERY_FREQUENCE_MS</c>
#define IFACE_TRACK_DEEP_TRACK_DEFAULT                   "true"                      // Default setting whether face entity is obtainable from tracked object in every video frame - parameter <c>IFACE_PARAMETER_TRACK_DEEP_TRACK</c>
#define IFACE_TRACK_MOTION_OPTIMIZATION_DEFAULT          IFACE_TRACK_MOTION_OPTIMIZATION_DISABLED   // Default setting defining how motion detection defines areas where object detection is performed - parameter <c>IFACE_PARAMETER_TRACK_MOTION_OPTIMIZATION</c>
#define IFACE_TRACK_TRACKING_MODE_DEFAULT                IFACE_TRACK_TRACKING_MODE_OBJECT_TRACKING  // Default tracking mode - parameter <c>IFACE_PARAMETER_TRACK_TRACKING_MODE</c>
#define IFACE_TRACK_MIN_DOT_POSITION_DEFAULT             "4"                         // Default value for minimal position count for dot-based liveness evaluation - parameter <c>IFACE_PARAMETER_TRACK_MIN_DOT_POSITION_COUNT</c>

#define IFACE_COUNT_CONFIDENCE_THRESHOLD_DEFAULT         "350"                      // Default value for face confidence threshold for object counting - parameter <c>IFACE_PARAMETER_COUNT_CONFIDENCE_THRESHOLD</c>
#define IFACE_COUNT_REDETECT_TIME_DELTA_DEFAULT          "10000"                    // Default value for maximal time difference between disjoint trajectories of the same object for object counting - parameter <c>IFACE_PARAMETER_COUNT_REDETECT_TIME_DELTA</c>
#define IFACE_COUNT_MATCH_THRESHOLD_DEFAULT              "50"                       // Default value for face template matching threshold for object counting - parameter <c>IFACE_PARAMETER_COUNT_MATCH_THRESHOLD</c>
#define IFACE_COUNT_TEMPLATE_MERGE_DEFAULT               "false"                    // Default value whether template merging can be used for object counting - parameter <c>IFACE_PARAMETER_COUNT_TEMPLATE_MERGE</c>
#define IFACE_COUNT_REQUIRE_MOVEMENT_DEFAULT             "true"                     // Default value whether stationary objects can represent valid targets for object counting - parameter <c>IFACE_PARAMETER_COUNT_REQUIRE_MOVEMENT</c>

//%<InnoDoc id=parameters_default_faceattr_cond_desc>
//% Default values of face attribute reliability conditions and dependencies.
//%</InnoDoc>

//%<InnoTable id=iface_faceattr_condition_default_values>
#define IFACE_FACE_ATTRIBUTE_COND_SHARPNESS_DEFAULT                  "SHARPNESS:<0;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                        // Default value of reliability condition and dependencies for facial sharpness - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SHARPNESS</c>
#define IFACE_FACE_ATTRIBUTE_COND_BRIGHTNESS_DEFAULT                 "BRIGHTNESS:<-5000;5000>&&YAW&&PITCH&&FACE_CONFIDENCE"                    // Default value of reliability condition and dependencies for facial brightness - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_BRIGHTNESS</c>
#define IFACE_FACE_ATTRIBUTE_COND_CONTRAST_DEFAULT                   "CONTRAST:<-5000;5000>&&YAW&&PITCH&&FACE_CONFIDENCE"                      // Default value of reliability condition and dependencies for facial contrast - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_CONTRAST</c>
#define IFACE_FACE_ATTRIBUTE_COND_UNIQUE_INTENSITY_LEVELS_DEFAULT    "UNIQUE_INTENSITY_LEVELS:<0;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"          // Default value of reliability condition and dependencies for facial unique intensity levels - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_UNIQUE_INTENSITY_LEVELS</c>
#define IFACE_FACE_ATTRIBUTE_COND_SHADOW_DEFAULT                     "SHADOW:<-200;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                        // Default value of reliability condition and dependencies for facial shadow - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SHADOW</c>
#define IFACE_FACE_ATTRIBUTE_COND_NOSE_SHADOW_DEFAULT                "NOSE_SHADOW:<-80;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                    // Default value of reliability condition and dependencies for facial sharp shadows - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_NOSE_SHADOW</c>
#define IFACE_FACE_ATTRIBUTE_COND_SPECULARITY_DEFAULT                "SPECULARITY:<-100;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                   // Default value of reliability condition and dependencies for facial specularity - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SPECULARITY</c>
#define IFACE_FACE_ATTRIBUTE_COND_EYE_GAZE_DEFAULT                   "EYE_GAZE:<-400;10000>&&EYE_STATUS_R&&EYE_STATUS_L&&FACE_CONFIDENCE"      // Default value of reliability condition and dependencies for eye gaze - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_GAZE</c>
#define IFACE_FACE_ATTRIBUTE_COND_EYE_STATUS_R_DEFAULT               "EYE_STATUS_R:<0;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                     // Default value of reliability condition and dependencies for right eye statue - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_STATUS_R</c>
#define IFACE_FACE_ATTRIBUTE_COND_EYE_STATUS_L_DEFAULT               "EYE_STATUS_L:<0;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                     // Default value of reliability condition and dependencies for left eye status - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_STATUS_L</c>
#define IFACE_FACE_ATTRIBUTE_COND_GLASS_STATUS_DEFAULT               "YAW&&PITCH&&FACE_CONFIDENCE"                                             // Default value of reliability dependencies for glass status - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_GLASS_STATUS</c>
#define IFACE_FACE_ATTRIBUTE_COND_HEAVY_FRAME_DEFAULT                "HEAVY_FRAME:<-10000;300>&&YAW&&PITCH&&FACE_CONFIDENCE"                   // Default value of reliability condition and dependencies for heavy frame - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_HEAVY_FRAME</c>
#define IFACE_FACE_ATTRIBUTE_COND_MOUTH_STATUS_DEFAULT               "MOUTH_STATUS:<0;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"                     // Default value of reliability condition and dependencies for mouth status - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_MOUTH_STATUS</c>
#define IFACE_FACE_ATTRIBUTE_COND_BACKGROUND_UNIFORMITY_DEFAULT      "BACKGROUND_UNIFORMITY:<-4000;10000>&&YAW&&PITCH&&FACE_CONFIDENCE"        // Default value of reliability condition and dependencies for background uniformity - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_BACKGROUND_UNIFORMITY</c>
#define IFACE_FACE_ATTRIBUTE_COND_AGE_DEFAULT                        "PITCH&&YAW&&SHARPNESS&&FACE_CONFIDENCE"                                  // Default value of reliability dependencies for person age estimation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_AGE</c>
#define IFACE_FACE_ATTRIBUTE_COND_RED_EYE_R_DEFAULT                  "RED_EYE_R:<-10000;0>&&EYE_STATUS_R&&FACE_CONFIDENCE"                     // Default value of reliability condition and dependencies for red-eye effect on right eye - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_RED_EYE_R</c>
#define IFACE_FACE_ATTRIBUTE_COND_RED_EYE_L_DEFAULT                  "RED_EYE_L:<-10000;0>&&EYE_STATUS_L&&FACE_CONFIDENCE"                     // Default value of reliability condition and dependencies for red-eye effect on left eye - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_RED_EYE_L</c>
#define IFACE_FACE_ATTRIBUTE_COND_ROLL_DEFAULT                       "ROLL:<-5000;5000>&&FACE_CONFIDENCE"                                      // Default value of reliability condition and dependencies for roll head orientation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_ROLL</c>
#define IFACE_FACE_ATTRIBUTE_COND_YAW_DEFAULT                        "YAW:<-5100;5000>&&FACE_CONFIDENCE"                                       // Default value of reliability condition and dependencies for yaw head orientation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_YAW</c>
#define IFACE_FACE_ATTRIBUTE_COND_PITCH_DEFAULT                      "PITCH:<-5500;4500>&&FACE_CONFIDENCE"                                     // Default value of reliability condition and dependencies for angle rotation of head towards camera referrence frame around Z-axis - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_PITCH</c>
#define IFACE_FACE_ATTRIBUTE_COND_ROLL_ANGLE_DEFAULT                 "ROLL_ANGLE:<-60;60>&&FACE_CONFIDENCE"                                    // Default value of reliability condition and dependencies for angle rotation of head towards camera referrence frame around X-axis - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_ROLL_ANGLE</c>
#define IFACE_FACE_ATTRIBUTE_COND_YAW_ANGLE_DEFAULT                  "YAW_ANGLE:<-60;60>&&FACE_CONFIDENCE"                                     // Default value of reliability condition and dependencies for angle rotation of head towards camera referrence frame around Y-axis - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_ANGLE_ANGLE</c>
#define IFACE_FACE_ATTRIBUTE_COND_PITCH_ANGLE_DEFAULT                "PITCH_ANGLE:<-60;60>&&FACE_CONFIDENCE"                                   // Default value of reliability condition and dependencies for head pitch angle - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_PITCH_ANGLE</c>
#define IFACE_FACE_ATTRIBUTE_COND_GENDER_DEFAULT                     "YAW&&PITCH&&FACE_CONFIDENCE"                                             // Default value of reliability dependencies for gender estimation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_GENDER</c>
#define IFACE_FACE_ATTRIBUTE_COND_SEGMENTATION_MASK_DEFAULT          "YAW&&PITCH&&FACE_CONFIDENCE"                                             // Default value of reliability dependencies for segmentation mask estimation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_SEGMENTATION_MASK</c>
#define IFACE_FACE_ATTRIBUTE_COND_CROP_DEFAULT                       "YAW&&PITCH&&FACE_CONFIDENCE"                                             // Default value of reliability dependencies for face cropping rectangle estimation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_CROP</c>
#define IFACE_FACE_ATTRIBUTE_COND_TEMPLATE_DEFAULT                   "FACE_CONFIDENCE"                                                         // Default value of reliability dependencies for recognition template creation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_TEMPLATE</c>
#define IFACE_FACE_ATTRIBUTE_COND_EYE_DISTANCE_DEFAULT               "FACE_CONFIDENCE"                                                         // Default value of reliability dependencies for eye distance estimation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_DISTANCE</c>
#define IFACE_FACE_ATTRIBUTE_COND_FACE_CONFIDENCE_DEFAULT            "FACE_CONFIDENCE:<600;10000>"                                             // Default value of reliability dependencies for face detection (fast/balanced/accurate mode) confidence - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_FACE_CONFIDENCE</c>
#define IFACE_FACE_ATTRIBUTE_COND_ANGLES_DEFAULT                     "FACE_CONFIDENCE"                                                         // Default value of reliability dependencies for face angles estimation - parameters <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_[ROLL/YAW/PITCH]_ANGLE</c>
#define IFACE_FACE_ATTRIBUTE_COND_FACE_SIZE_DEFAULT                  "FACE_CONFIDENCE"                                                         // Default value of reliability dependencies for eye distance estimation - parameter <c>IFACE_PARAMETER_FACE_ATTRIBUTE_COND_EYE_DISTANCE</c>

//%</InnoTable>


#define MAX_FACE_CONFIDENCE     10000   // Maximal confidence of detected face

#endif
