/* This header file contains IFace SDK API functions
   declarations.                                     */
#ifndef _IFACE_H
#define _IFACE_H

#ifdef __cplusplus
extern "C" {
#endif

// Specification of storage-class information. It enables to export and import functions, data, and objects to and from a DLL..
#if defined(_WIN32) || defined(__WIN32__)
    #if defined(iface_EXPORTS)
        #define  IFACE_API __declspec(dllexport)
    #else
        #define  IFACE_API __declspec(dllimport)
    #endif
#elif defined(linux) || defined(__linux)
    #if __GNUC__ >= 4
        #define IFACE_API __attribute__ ((visibility ("default")))
    #else
        #define IFACE_API
    #endif
#endif

#ifdef __APPLE__
#define IFACE_API __attribute__((visibility ("default")))
#endif

#include "iface_error_codes.h"
#include "iface_defs.h"
#include "iface_param_names.h"

/*
Summary:
    Returns the library version.
Parameters:
    major - [out] Major version of the library
    minor - [out] Minor version of the library
    revision - [out] Revision
Return value:
    error code
*/
IFACE_API int IFACE_GetVersionInfo( int* major, int* minor, int* revision );

/*
Summary:
        Returns product name and version formatted as string (e.g., IFace SDK v3.2.4.0)
*/
IFACE_API const char * IFACE_GetProductString();

/*
Summary:
    Returns error message describing given error code.
Parameters:
    errorCode - [in] error code returned from IFace functions
    bufferSize - [in] size of buffer where the error message is written.
                 If the message length is longer then the buffer size then the message is cut off.
    buffer - [out] buffer where the error message is written
Return value:
    error code
*/
IFACE_API int IFACE_GetErrorMessage(int errorCode, unsigned int bufferSize, char* buffer);

/*
Summary:
    Returns hardware ID of device for licensing purposes.
Parameters:
    hwId - [out] Pointer to the memory where hardware ID will be saved. If hwId is set to NULL, only length is returned.
    length - [in/out] in: total size of allocated memory pointed by the hwId parameter,
             out: required or actually used size of hwId
Remarks:
    If <c>hwId==NULL<c/> length of hwId is calculated and returned, otherwise data are filled
Return value:
    error code
*/
IFACE_API int IFACE_GetHardwareId(char* hwId, int* length);

/*
Summary:
   Returns value of given key from actually used license.
Parameters:
   key - [in] Key to required value, use "/" for key levels, e.g. "/version", "/contract/customer".
         Arrays are indexed form 0, i.e.: use "/contract/hwids/0" for the first element of "hwids" array.
   value - [out] Pointer to the memory space where value of given key will be saved (as null-terminated string).
   valueLength - [in/out] On input, valueLength parameter is interpreted as total size of allocated memory pointed by
                 the value parameter. On return, this parameter will be equal to the total length of value.
Remarks:
   This function uses two-phase buffer retrieval algorithm.
Return value:
   error code
*/
IFACE_API int IFACE_GetLicenseValue(const char *key, char *value, int *valueLength);

/*
Summary:
    Initializes IFace SDK and checks validity of IFace SDK software license from license file.
Return value:
    error code
*/
IFACE_API int IFACE_Init();

/*
Summary:
    Terminates IFace and releases all used resources.
Return value:
    error code
*/
IFACE_API int IFACE_Terminate();

/*
Summary:
    Initializes IFACE SDK and checks validity of IFace SDK software license from given license data string.
Parameters:
    licenseData	- [in] license data
    licenseDataSize	- [in] license data size
Return value:
    error code
*/
IFACE_API int IFACE_InitWithLicence( const unsigned char *licenseData, const int licenseDataSize );

/*
Summary:
    Initializes and turns on IFace logger. Log messages related to IFace processing having different
    severity levels are written into defined file or to stdout.
Parameters:
    severityLevel - [in] logging severity level. Only events >= severityLevel are logged.
    dstPath - [in] null-terminated string containing path to the log file.
Remarks:
    If <c>dstPath==NULL<c/> then log messages are redirected to stdout.
    To disable logging, set <c>dstPath<c/> to <c>""<c/> at any <c>securityLevel<c/>.
Return value:
    error code
*/
IFACE_API int IFACE_SetLogger( IFACE_LoggerSeverityLevel severityLevel, const char* dstPath );

/*
Summary:
    Creates and initializes data structure for given entity.
Parameters:
    type - [in] type of entity to be created. Value from IFACE_EntityType,
           except IFACE_ENTITY_TYPE_OBJECT_HANDLER and IFACE_ENTITY_TYPE_OBJECT.
    entity - [out] pointer to newly created entity if created successfully, NULL otherwise.
Return value:
    error code
*/
IFACE_API int IFACE_CreateEntity( IFACE_EntityType type, void** entity );

/*
Summary:
    Creates and initializes face handler entity. Face handler entity contains data and parameters
    related to face processing (face detection, face matching, etc.).
Parameters:
    faceHandler - [out] pointer to newly created face handler entity if created successfully, NULL otherwise.
Remarks:
    This function is deprecated in favor of <c>IFACE_CreateEntity</c>
Return value:
    error code
*/
IFACE_API int IFACE_CreateFaceHandler( void** faceHandler );

/*
Summary:
Creates empty face entity. After face detection and processing with face related API
functions contains face entity specific data (features positions, face attributes, face template, etc.)
Parameters:
    face - [out] pointer to newly created face if created successfully, NULL otherwise.
Remarks:
    This function is deprecated in favor of <c>IFACE_CreateEntity</c>
Return value:
    error code
*/
IFACE_API int IFACE_CreateFace( void** face );

/*
Summary:
    Serializes face entity content to byte array.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    serializedFace - [in/out] in: pointer to an allocated array that will be filled with serialized
                     face entity data, out: filled data
    serializedFaceSize - [in/out] in: size of the allocated array, out: size of serialized face entity data
Remarks:
    If <c>serializedFace==NULL<c/> then just size of serialized face entity is returned
    This function is deprecated in favor of <c>IFACE_SerializeEntity</c>
Return value:
    error code
*/
IFACE_API int IFACE_SerializeFace( void* face, void* faceHandler, char* serializedFace, int* serializedFaceSize);

/*
Summary:
    Deserialize face entity content from byte array.
Parameters:
    face - [in/out] in: pointer to a face entity, out: pointer to the same entity, filled with serialized face entity data
    faceHandler - [in] pointer to face handler entity
    serializedFace - [in] pointer to memory filled with serialized face entity data
    serializedFaceSize - [in] length of data in serializedFace array
Remarks:
    This function is deprecated in favor of <c>IFACE_DeserializeEntity</c>
Return value:
    error code
*/
IFACE_API int IFACE_DeserializeFace( void* face, void* faceHandler, char* serializedFace, int serializedFaceSize);

/*
Summary:
    Sets value to defined user parameter. Parameter can be related to specific entity or can be global.
Parameters:
    entity - [in] pointer to entity if parameter is entity related. If parameter is global then
             the entity parameter must be set to IFACE_GLOBAL_PARAMETERS (NULL).
             Global parameters can be set only before calling IFACE_Init() or after calling IFACE_Terminate().
             Global parameters are switched to read-only mode after calling IFACE_Init() and before calling IFACE_Terminate().
    parameterName - [in] parameter name
    parameterValue - [in] parameter value
Return value:
    error code
*/
IFACE_API int IFACE_SetParam( void* entity, const char* parameterName, const char* parameterValue );

/*
Summary
   Gets user parameter size.
Parameters
    entity - [in] pointer to entity if parameter is entity related. If parameter is global then
             the entity parameter must be set to IFACE_GLOBAL_PARAMETERS (NULL).
    parameterName - [in] parameter name
    parameterValueSize - [out] size of buffer that must be allocated for the parameter value
Return value:
   error code
*/
IFACE_API int IFACE_GetParamSize( void* entity, const char* parameterName, unsigned int* parameterValueSize);

/*
Summary:
    Gets user parameter value.
Parameters:
    entity - [in] pointer to entity if parameter is entity related. If parameter is global then
             the entity parameter must be set to IFACE_GLOBAL_PARAMETERS (NULL).
    parameterName - [in] parameter name
    parameterValue - [out] parameter value
    parameterValueSize - [in] total size of allocated memory pointed by the value parameter.
Return value:
    error code
*/
IFACE_API int IFACE_GetParam( void* entity, const char* parameterName, char* parameterValue, unsigned int parameterValueSize);

/*
Summary
   Detects all/requested count entities in given image and sets detection results into given
   preallocated entities (using given detectionHandler entity).
Parameters
   rawImage - [in] pointer to raw image data, each pixel has 3 components (bytes) in BGR order
   width - [in] width of input image. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input image. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   minEntitySize - [in] defines minimal size of detected entity.
                   If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                   Otherwise it is considered as entity size in pixels.
                   Minimal valid value can be retrieved from parameter IFACE_PARAMETER_MIN_VALID_FACE_SIZE. TODO Martin rewrite - pedestrians value (IFACE_PARAMETER_MIN_VALID_FACE_SIZE)?
   maxEntitySize - [in] defines maximal size of detected entity.
                   If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                   Otherwise it is considered as entity size in pixels.
   detectionHandler - [in] pointer to detection handler entity
   entitiesCnt - [in/out] in: max count of entities to be detected in given image, out: count of detected entities
   entities - [in/out] in: array of pointers entities created by <c>IFACE_CreateEntity</c>, out: same entities,
              filled with detection information
Return value:
   error code
*/
IFACE_API int IFACE_Detect(
    unsigned char* rawImage, int width, int height, float minEntitySize, float maxEntitySize,
    void* detectionHandler, int* entitiesCnt, void** entities
);

/*
Summary
   Detects all/requested count faces in given image and sets face detection results into given
   preallocated face entities (using given face handler entity).
Parameters
   rawImage - [in] pointer to raw image data, each pixel has 3 components (bytes) in BGR order
   width - [in] width of input image. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input image. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   minFaceSize - [in] defines minimal size of detected faces.
                 If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                 Otherwise it is considered as face size in pixels.
                 Minimal valid value can be retrieved from parameter IFACE_PARAMETER_MIN_VALID_FACE_SIZE.
   maxFaceSize - [in] defines maximal size of detected faces.
                 If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                 Otherwise it is considered as face size in pixels.
   faceHandler - [in] pointer to face handler entity
   facesCount - [in/out] in: max count of faces to be detected in given image, out: count of detected faces
   faces - [in/out] in: array of pointers to face entities, out: same face entities, filled with detected faces
Return value:
   error code
*/
IFACE_API int IFACE_DetectFaces(
    unsigned char* rawImage, int width, int height, float minFaceSize, float maxFaceSize,
    void* faceHandler, int* facesCount, void** faces
);


/*
Summary
   Detects all/requested count faces in given batch of images and sets face detection results into given
   preallocated face entities (using given face handler entity).
Parameters
   imagesCount - [in] number of input images.
   rawImages - [in] array of pointers to raw images data, each pixel has 3 components (bytes) in BGR order. All input
               images must have the same dimensions.
   width - [in] width of input images. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input images. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   minFaceSize - [in] defines minimal size of detected faces.
                 If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                 Otherwise it is considered as face size in pixels.
                 Minimal valid value can be retrieved from parameter IFACE_PARAMETER_MIN_VALID_FACE_SIZE.
   maxFaceSize - [in] defines maximal size of detected faces.
                 If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                 Otherwise it is considered as face size in pixels.
   faceHandler - [in] pointer to face handler entity
   facesCounts - [in/out] in: array (with imagesCount items) of max counts of faces to be detected in given images,
                 out: array of counts of detected faces in each input image
   faces - [in/out] in: array of array of pointers to face entities, out: same face entities, filled with detected faces
Return value:
   error code
*/
IFACE_API int IFACE_DetectFacesBatch(
    unsigned int imagesCount, unsigned char* rawImages[], const int width, const int height, float minFaceSize,
    float maxFaceSize, void* faceHandler, int* facesCounts, void** faces[]
);


/*
Summary
   Detects dominant face in given image and sets face detection results into given
   preallocated face entity. This API function can be used in scenario when face is in image for sure,
   but the quality of the image is not high. Various strategies are used to find the face. If more faces
   are present on the image then the most dominant face (having the biggest bounding box) is selected.
Parameters
   rawImage - [in] pointer to raw image data, each pixel has 3 components (bytes) in BGR order
   width - [in] width of input image. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input image. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   minFaceSize - [in] defines minimal size of detected faces.
                 If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                 Otherwise it is considered as face size in pixels.
                 Minimal valid value can be retrieved from parameter IFACE_PARAMETER_MIN_VALID_FACE_SIZE.
   maxFaceSize - [in] defines maximal size of detected faces.
                 If it is in range (0., 1> then it is relative to maximum of the input image dimensions.
                 Otherwise it is considered as face size in pixels.
   faceHandler - [in] pointer to face handler entity
   facesFound - [out] out: count of detected faces (it can be 0 or 1)
   face - [in/out] in: pointer to face entity that will be filled with detected face

Remarks
    This function API is different to IFACE_DetectFaces. The difference is in face (vs faces) parameter.
    In IFACE_DetectFaceForced is expected pointer to face entity to be filled while in case of IFACE_DetectFaces
    array of pointers to face entities to be filled (generally more faces can be found) is expected.
    Not available in IFace Tiny edition.
Return value:
   error code
*/
IFACE_API int IFACE_DetectFaceForced(
    unsigned char* rawImage, int width, int height, float minFaceSize, float maxFaceSize,
    void* faceHandler, int* facesFound, void* face);


/*
Summary
   Detects fixed number of faces at predefined positions in a given image and fills preallocated face entities using face handler entity.
Parameters
   rawImage - [in] pointer to raw image data, each pixel has 3 components (bytes) in BGR order
   width - [in] width of input image. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input image. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   facesCount - [in] count of faces, size of the following arrays
   rightEyesX - [in] x coordinates of right eyes
   rightEyesY - [in] y coordinates of right eyes
   leftEyesX - [in] x coordinates of left eyes
   leftEyesY - [in] y coordinates of left eyes
   faceHandler - [in] pointer to face handler entity
   faces - [in/out] in: array of pointers to face entities, out: same entities, filled with detected faces.
           Detected faces are confidence sorted using descending order, so the face with highest confidence
           has the highest score.
Return value:
   error code
*/
IFACE_API int IFACE_DetectFacesAtPositions(unsigned char* rawImage, int width, int height, int facesCount,
    float* rightEyesX, float* rightEyesY, float* leftEyesX, float* leftEyesY,
    void* faceHandler, void** faces);


/*
Summary
   Detects all/requested count faces of specific size (defined by minimum area) in given image
   and sets face detection results into given preallocated face entities (using given face handler entity).
Parameters
   rawImage - [in] pointer to raw image data, each pixel has 3 components (bytes) in BGR order
   width - [in] width of input image. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input image. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   minFaceArea - [in] defines minimal area (relative to image size) of detected faces.
   faceHandler - [in] pointer to face handler entity
   facesCount - [in/out] in: max count of faces to be detected in given image, out: count of detected faces
   faces - [in/out] in: array of pointers to face entities, out: same face entities, filled with detected faces
Return value:
   error code
*/
IFACE_API int IFACE_DetectFacesOfArea(
    unsigned char* rawImage, int width, int height, float minFaceArea,
    void* faceHandler, int* facesCount, void** faces
);


/*
Summary
   Detects all/requested count faces in given batch of images and sets face detection results into given
   preallocated face entities (using given face handler entity).
Parameters
   imagesCount - [in] number of input images.
   rawImages - [in] array of pointers to raw images data, each pixel has 3 components (bytes) in BGR order. All input
               images must have the same dimensions.
   width - [in] width of input images. Minimal valid width can be retrieved
           from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   height - [in] height of input images. Minimal valid height can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
   minFaceArea - [in] defines minimal area (relative to image size) of detected faces.
   faceHandler - [in] pointer to face handler entity
   facesCounts - [in/out] in: array (with imagesCount items) of max counts of faces to be detected in given images,
                 out: array of counts of detected faces in each input image
   faces - [in/out] in: array of array of pointers to face entities, out: same face entities, filled with detected faces
Return value:
   error code
*/
IFACE_API int IFACE_DetectFacesOfAreaBatch(
    unsigned int imagesCount, unsigned char* rawImages[], const int width, const int height, float minFaceArea,
    void* faceHandler, int* facesCounts, void** faces[]
);


/*
Summary:
    Retrieves basic info about face (eyes position and face score).
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    rightEyeX -   [out] x coordinate of right eye
    rightEyeY -   [out] y coordinate of right eye
    leftEyeX -    [out] x coordinate of left eye
    leftEyeY -    [out] y coordinate of left eye
    faceScore -   [out] face score from range <0, MAX_FACE_CONFIDENCE>.
                        The higher the value of the score the better quality of the face.

Return value:
    error code
*/
IFACE_API int IFACE_GetFaceBasicInfo( void* face, void* faceHandler,
    float* rightEyeX, float* rightEyeY,
    float* leftEyeX, float* leftEyeY,
    float* faceScore);

/*
Summary:
    Retrieves basic info about pedestrian (bounding box and detection score).
Parameters:
    pedestrian -        [in] pointer to pedestrian entity
    pedestrianHandler - [in] pointer to detection handler entity
    x -                 [out] x coordinate of top left corner of bounding box
    y -                 [out] y coordinate of top left corner of bounding box
    width -             [out] x coordinate of left eye
    height -            [out] y coordinate of left eye
    pedestrianScore -   [out] pedestrian score from range <0, MAX_PEDESTRIAN_CONFIDENCE>.         TODO Martin create MAX_PEDESTRIAN_CONFIDENCE
                        The higher the value of the score the better quality of the pedestrian.

Return value:
    error code
*/
IFACE_API int IFACE_GetPedestrianBasicInfo( void* pedestrian, void* pedestrianHandler,
    float* x, float* y,
    float* width, float* height,
    float* score);

/*
Summary:
    Retrieves given facial features (position and score) using specified face. Position is in float precision.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    requestedFeatures - [in] array of requested features
    numFeatures - [in] number of requested features; requestedFeatures / posX / posY / score has this count of elements
    posX - [out] array of x coordinates related to requestedFeatures
    posY - [out] array of y coordinates related to requestedFeatures
    score - [out] array of scores related to requestedFeatures.
            The score can have special values if feature is not detectable (IFACE_FACE_FEATURE_STATE_UNDETECTABLE) or
            the score for the feature is not defined (IFACE_FACE_FEATURE_STATE_DETECTABLE_NO_CONFIDENCE).
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceFeatures( void* face, void* faceHandler, IFACE_FaceFeatureId* requestedFeatures, int numFeatures, float* posX, float* posY, float* score );

//%<InnoDoc id=iface_icao_evaluation_desc>
//% Functions <c>IFACE_GetFaceAttribute</c>, <c>IFACE_GetFaceAttributeDependenciesStatus</c> and <c>IFACE_GetFaceAttributeRangeStatus</c>
//% retrieve ICAO status of various ICAO features (some of face attributes, see </c>IFACE_FaceAttributeId</c>). Reliability of each
//% face attribute can be dependent on several other face attributes. For example eye-gaze status can be be correctly
//% evaluated only when face has frontal position and both eyes are open. It means that eye-gaze status is dependent on
//% features yaw, pitch, right eye-status and left eye status. Once the conditions defined on these referenced features
//% are fulfilled then can be dependent ICAO feature correctly evaluated.
//% The status consist of three parts:
//%
//%  1. <b>score of ICAO feature</b> - score (value) of desired face attribute, which can be retrieved by
//%  function <c>IFACE_GetFaceAttribute</c>
//%
//%  2. <b>dependencies status of ICAO feature</b> - fulfillment of conditions defined on referenced face attributes (desired
//%  feature is depending on them) can be retrieved by function <c>IFACE_GetFaceAttributeDependenciesStatus</c>.
//%  Possible values are enumerated in <c>IFACE_FaceAttributeDependenciesStatus</c>.
//%
//%  3. <b>reliability range status of ICAO feature</b> - reliability range status of desired ICAO feature can be
//%  retrieved be function <c>IFACE_GetFaceAttributeRangeStatus</c>. Possible values are enumerated in
//%  <c>IFACE_FaceAttributeRangeStatus</c>.
//%
//% Once an ICAO feature score is in reliability range and the conditions defined on referenced face attributes
//% are fulfilled then the feature is ICAO compliant.
//%</InnoDoc>

/*
Summary:
    Returns value of desired facial attribute. Attributes producing numeric score values
    (e.g. mouth status, eyes status etc.) can be calculated  using this API function.
    Moreover some other attributes like age, eye-distance, gender etc. can be
    evaluated using this API function. Complete set of available attributes are enumerated
    in IFACE_FaceAttributeId.  Attributes not returning numeric values can't be
    passed into IFACE_GetFaceAttribute (e.g. segmentation mask).
    This API function can be used for ICAO compliance evaluation of some of face attributes.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    fattrId - [in] defines which facial attribute is evaluated.
           Possible values are enumerated in IFACE_FaceAttributeId.
    fattrValue - [out] value of desired facial attribute
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceAttribute( void *face, void *faceHandler, const IFACE_FaceAttributeId fattrId, float *fattrValue );

/*
Summary:
    Returns raw (unnormalized) value of desired facial attribute. Complete set of available
    attributes are enumerated in IFACE_FaceAttributeId (only numeric attributes can be
    passed into IFACE_GetFaceAttributeRaw)
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    fattrId - [in] defines which facial attribute is evaluated.
              Possible values are enumerated in IFACE_FaceAttributeId.
    fattrValueRaw - [out] raw (unnormalized) value of desired facial attribute
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceAttributeRaw( void *face, void *faceHandler, const IFACE_FaceAttributeId fattrId, float *fattrValueRaw );

/*
Summary:
    Retrieves fulfillment of dependencies which are necessary for valid
    face attribute evaluation (desired attribute is depending on them).
    If dependencies of desired feature are not fulfilled then validity
    of face attribute is not guaranteed.
    This API function can be used for ICAO compliance evaluation of some of face attributes.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    fattrId - [in] defines which face attribute is evaluated.
              Possible values are enumerated in IFACE_FaceAttributeId.
    fattrDependenciesStatus - [out] fulfillment of face attribute dependencies (desired attribute
                              is depending on them). Possible values are enumerated in
                              IFACE_FaceAttributeDependenciesStatus.
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceAttributeDependenciesStatus( void *face, void *faceHandler, const IFACE_FaceAttributeId fattrId, IFACE_FaceAttributeDependenciesStatus *fattrDependenciesStatus );

/*
Summary:
    Retrieves reliability range status of desired face attribute.
    Only features producing numeric values can be evaluated - see documentation of IFACE_FaceAttributeId.
    This API function can be used for ICAO compliance evaluation of some of face attributes.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    fattrId - [in] defines which face attribute is evaluated.
              Possible values are enumerated in IFACE_FaceAttributeId.
    rangeStatus - [out] range compliance status of desired face attribute. Possible values are enumerated in
                  IFACE_FaceAttributeRangeStatus.
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceAttributeRangeStatus( void *face, void *faceHandler, const IFACE_FaceAttributeId fattrId, IFACE_FaceAttributeRangeStatus *rangeStatus );

/*
Summary:
    Retrieves face image with background / foreground segmented. The segmentation image is cropped according to the selected
    cropping method <c>IFACE_FaceCropMethod</c>. The types of segmentation can be selected from <c>IFACE_SegmentationImageType</c>.
    The segmentation of hairstyle can be tuned by setting matting to <c>IFACE_PARAMETER_SEGMENTATION_MATTING_TYPE</c> parameter.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    cropMethod - [in] face cropping method according to the IFACE_FaceCropMethod enum
    segImageType - [in] type of output segmentation image type according to the IFACE_SegmentationImageType enum
    segImageWidth - [out] width of segmentation image
    segImageHeight - [out] height of segmentation image
    segImageChannels - [out] count of segmentation image channels
    segImageLength - [out] segmentation image length
    segImageRaw - [out] image data to be filled
Remarks:
    If <c>segImageRaw==NULL<c/> only segmentation image length (and dimensions) is returned.
    Only available in IFace Server edition
 Returns
    error code
 */
IFACE_API int IFACE_GetFaceSegmentation( void* face, void* faceHandler, IFACE_FaceCropMethod cropMethod, IFACE_SegmentationImageType segImageType,
    int* segImageWidth, int* segImageHeight, int* segImageChannels, int* segImageLength, unsigned char* segImageRaw);

/*
Summary:
    Retrieves cropping rectangle of entity.
Parameters:
    entity -      [in] pointer to entity. Supports only pedestrian entity for now. Use <c>IFACE_GetFaceCropRectangle</c>
                  to get segmentation of face.
    detectionHandler -  [in] pointer to detection handler
    cropRect -    [out] array of X and Y values of crop quadrilateral corners in following order:
                  X top-left, Y top-left, X top-right, Y top-right, X bottom-left, Y bottom-left, X bottom-right, Y bottom-right
Return value:
    error code
*/
IFACE_API int IFACE_GetCropRectangle( void* entity, void* detectionHandler, float cropRect[8] );

/*
Summary:
    Retrieves face cropping rectangle according to the selected cropping method.
Parameters:
    face - [in] pointer to face entity
    faceHandler -  [in] pointer to face handler entity
    cropMethod -  [in] face cropping method according to the IFACE_FaceCropMethod enum
    cropRect -    [out] array of X and Y values of crop quadrilateral corners in following order:
                  X top-left, Y top-left, X top-right, Y top-right, X bottom-left, Y bottom-left, X bottom-right, Y bottom-right
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceCropRectangle( void* face, void* faceHandler, IFACE_FaceCropMethod cropMethod, float cropRect[8] );

/*
Summary:
    Retrieves face image cropped according to the selected cropping method.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    cropMethod - [in] face cropping method according to the IFACE_FaceCropMethod enum
    cropWidth - [out] width of cropped image
    cropHeight - [out] height of cropped image
    cropLength - [out] cropped image length
    rawCroppedImage - [out] image data to be filled
Remarks:
    If <c>rawCroppedImage==NULL<c/> only cropped image length is returned
Returns
    error code
*/
IFACE_API int IFACE_GetFaceCropImage( void* face, void* faceHandler, IFACE_FaceCropMethod cropMethod, int* cropWidth, int* cropHeight, int* cropLength, unsigned char* rawCroppedImage);

/*
Summary:
    Retrieves face verification template.
Parameters:
    face - [in] pointer to face entity
    faceHandler - [in] pointer to face handler entity
    reserved - [in] reserved for future use
    templateSize - [out] template data length
    faceTemplate - [out] template data that can be used in function IFACE_MatchTemplate
Remarks:
    If <c>faceTemplate==NULL<c/> template size is calculated and returned, otherwise data are filled
Return value:
    error code
*/
IFACE_API int IFACE_CreateTemplate( void* face, void* faceHandler, int reserved, int *templateSize, char *faceTemplate );

/*
Summary:
    Retrieves information about verification template
Parameters:
    faceHandler - [in] pointer to face handler entity
    faceTemplate - [in] face verification template
    majorVersion - [out] major version of the template
    minorVersion - [out] minor version of the template
    quality - [out] quality of the verification template, 0 - undefined, 1 - min quality, 255 - max quality
Return value:
    error code
*/
IFACE_API int IFACE_GetTemplateInfo( void* faceHandler, char *faceTemplate, int *majorVersion, int *minorVersion, int* quality );

/*
Summary:
    Averages templates given as input
Parameters:
    faceHandler - [in] pointer to face handler entity
    inTemplateArray - [in] array of templates to be averaged
    inTemplateCount - [in] count of templates in inTemplateArray
    templateSize - [out] template data length
    outTemplate - [out] averaged template
Return value:
    error code
*/
IFACE_API int IFACE_AverageTemplates(void* faceHandler, char** inTemplateArray, int inTemplateCount,
    int *templateSize, char* outTemplate);


/*
Summary:
   Compares the similarity of two face templates and calculates
   their matching score. It is implementation of one to one
   matching known as verification.
Remarks:
   Only templates with compatible versions can be compared. Template version can be found by API function <c>IFACE_GetTemplateInfo</c>.
   Templates can be created using various face verification extraction modes (stored in <c>IFACE_PARAMETER_FACETMPLEXT_SPEED_ACCURACY_MODE</c>).
Parameters:
   faceHandler - [in] pointer to face handler entity
   faceTemplate1 - [in] face verification template created by IFACE_CreateTemplate
   faceTemplate2 - [in] face verification template created by IFACE_CreateTemplate
   score - [out] Matching score range is <0, 100>. Its values can be interpreted as follows:
   1) Low values of the score, i.e. range <0, 60>, are normalized using FAR values and this formula score_L=-10*log(FAR).
      It means that score 30 is related to FAR=1:1000=10^-3, score 50 is related to FAR=1:100000=10^-5
      (evaluated on our large testing non-matching pairs dataset).
   2) High values of the score, i.e. range <80, 100>, are normalized using FRR values and this formula score_H=100/3*(FRR + 2).
      It means that score 80 is related to FRR=0.4, score 90 is related to FRR=0.7 (evaluated on our large testing matching pairs dataset).
   3) Scores values in range (60, 80) are weighted average of score_L and score_H.
      This normalization help the users to select the score threshold according their needs.
      If it is too low e.g. score_thold = 30, then the chance of false accepted non-matching
      faces is quite high (FAR=10^-3). When it is too high e.g. score_thold = 90, then the chance of false
      rejected matching faces is quite high (FRR=0.7).
Return value:
   error code
*/
IFACE_API int IFACE_MatchTemplate( void* faceHandler, char* faceTemplate1, char* faceTemplate2, float *score );

/*
Summary:
    Retrieves array of face templates from array of face entities
Parameters:
    faceHandler - [in] pointer to face handler entity
    facesCount - [in] count of face in given face entities array
    faces - [in] array of face entities
    templateSize - [out] template data length
    faceTemplates - [out] array of face templates
Remarks:
    Only available in IFace Server edition
Return value:
    error code
*/
IFACE_API int IFACE_CreateTemplateBatch( void *faceHandler, int facesCount, void **faces, int *templateSize, char **faceTemplates );

/*
Summary:
     Auxiliary function for loading source image from a memory buffer, into raw image format (appropriate for usage in IFace)
Parameters:
    imgData - [in] pointer to a memory buffer containing source image data (png, bmp, tif, jpg formats are supported)
    size - [in] size of the image
    width - [out] image width
    height - [out] image height
    length - [out] image data length
    rawImage - [out] prepared memory buffer to be filled with image data (each pixel has 3 components (bytes) in BGR order for raw image data).
Remarks:
    If <c>rawImage==NULL<c/> then just source image dimensions and data length are returned, otherwise data are filled.
Return value:
    error code
*/
IFACE_API int IFACE_LoadImageFromMemory( const char* imgData, int size,  int* width, int* height, int* length, unsigned char* rawImage );

/*
Summary:
    Auxiliary function that encodes a raw image from memory buffer, into memory buffered image formated as rawChannels channels image of specified type (e.g. bmp, jpg, png format) in imageType
Parameters:
    rawImage - [in] memory buffer filled with raw image data (each pixel has 3 components (bytes) in BGR order)
    rawWidth - [in] width of the raw image
    rawHeight - [in] height of the raw image
    rawChannels - [in] number of channels of the raw image
    imageType - [in] type of image to be written into memory buffer according to IFACE_ImageSaveType
    imageSize - [out] size of the resulting image memory buffer
    image - [out] pointer to memory buffer (array of bytes to be filled resulting image).
Remarks:
    If <c>image==NULL<c/> then just size of resulting image imageSize is returned, otherwise data are filled.
    Not available in IFace Tiny edition
Return value:
    error code
*/
IFACE_API int IFACE_SaveImageToMemory( unsigned char* rawImage, int rawWidth, int rawHeight, int rawChannels, IFACE_ImageSaveType imageType, int * imageSize, unsigned char* image);

/*
Summary:
   Auxiliary function for saving raw image data into file.
Parameters:
   fileName - [in] image file to be saved. Target format is
               defined by filename extension (png, bmp, tif, jpg formats are supported)
   width - [in] image width
   height - [in] image height
   channels - [in] image channels count
   rawImage - [in] raw image data (each pixel has 3 components
              (bytes) in BGR order or 4 components (bytes) in BGRA order (A stands for Alpha transparent channel))
Remarks:
    Not available in IFace Tiny edition
Return value:
   error code
*/
IFACE_API int IFACE_SaveImage( const char* fileName, int width, int height, int channels, unsigned char* rawImage );

/*
Summary:
   Auxiliary function for loading source image from file, into
   raw image format (appropriate for usage in IFace)
Parameters:
   fileName - [in] file path of source image to be loaded (png,
              bmp, tif, jpg formats are supported)
   width - [out] image width
   height - [out] image height
   length - [out] image data length
   rawImage - [out] prepared memory buffer to be filled with
              raw image data (each pixel has 3 components
              (bytes) in BGR order).
Remarks:
    If <c>rawImage==NULL</c> then just source image dimensions and data length are returned.
    Otherwise data are filled.
Return value:
   error code
*/
IFACE_API int IFACE_LoadImage( const char* fileName, int* width, int* height, int* length, unsigned char* rawImage );

/*
Summary:
   Sets the face features into face entity. Only selected facial features are set.
Parameters:
   face - [in] pointer to face entity
   faceHandler - [in] pointer to face handler entity
   rawImage - [in] pointer to image data, 3 components in BGR order
   width - [in] image width
   height - [in] image height
   features - [in] array of selected facial features
   numFeatures - [in] number of selected facial features
   posX - [in] given x positions of selected facial features
   posY - [in] given y positions of selected facial features
   faceScore - [in] score of face (use 0.0f if you do not want to set it)
Remarks:
   Auxiliary function which can be used for accuracy tests.
Return value:
   error code
*/
IFACE_API int IFACE_SetFaceFeatures( void* face, void *faceHandler,
    unsigned char* rawImage, int width, int height,
    IFACE_FaceFeatureId* features, int numFeatures, float *posX, float *posY,
    float faceConfidence);

/*
Summary:
    Creates and initializes object handler entity.
Parameters:
    objectHandler - [out] pointer to newly created object handler entity if created successfully, NULL otherwise.
    detectionHandler - [in] handler entity usable for object detection (currently face handler entity can be used only)
Return value:
    error code
*/
IFACE_API int IFACE_CreateObjectHandler( void** objectHandler, void* detectionHandler );

/*
Summary:
    Creates empty object entity.
Parameters:
    object - [out] pointer to newly created object entity if created successfully, NULL otherwise.
Return value:
    error code
*/
IFACE_API int IFACE_CreateObject( void** object );

/*
Summary:
    Performs tracking of objects in video sequence. Just one video frame (<c>rawImage</c>,
    supplemented by time info <c>timeStampMs</c>) is processed in one call of
    IFACE_TrackObjects function. The state of tracked objects is stored
    in <c>objects</c> array. Objects of detection handler entity type (e.g. face handler entity for face objects)
    set to object handler entity (in IFACE_CreateObjectHandler call) are detected and tracked.
Parameters:
    objectHandler - [in] pointer to object handler entity
    rawImage - [in] pointer to raw image data, each pixel has 3 components (bytes) in BGR order
    width - [in] width of input image. Minimal valid width can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
    height - [in] height of input image. Minimal valid height can be retrieved
             from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
    timeStampMs - [in] number of ms from the video first frame
    objectsCount - [in] count of tracked objects
    objects - [in/out] in: array of object entity pointers to be filled, out: tracked object entities
Remarks:
    With tracking mode <c>IFACE_TRACK_TRACKING_MODE_LIVENESS_DOT</c> (parameter <c>IFACE_PARAMETER_TRACK_TRACKING_MODE</c>)
    enabled, liveness check tracking is performed. Tracked face image cannot be mirrored due to liveness evaluation needs.
    Image dimensions must stay fixed in the same tracking session.
Return value:
    error code
*/
IFACE_API int IFACE_TrackObjects( void* objectHandler, unsigned char* rawImage, int width, int height, long long timeStampMs, int objectsCount, void** objects);

/*
Summary:
    Sets objects for tracking. Objects are defined by position
    (<c>xs</c>, <c>ys</c>) and size (<c>widths</c>, <c>heights</c>).
Parameters:
    objectHandler - [in] pointer to object handler entity
    objectsCount - [in] count of object entities
    objects - [in/out] array of pointers to object entities
    setObjectsCount - [in] number of objects that should be set. It defines the size of xs, ys, widths and heights array
    xs - [in] x-coordinates of objects bounding box
    ys - [in] y-coordinates of objects bounding box
    widths - [in] widths of objects bounding box
    heights - [in] heights of objects bounding box
Return value:
    error code
*/
IFACE_API int IFACE_SetTrackingObjects( void* objectHandler, int objectsCount, void** objects, int setObjectsCount, int* xs, int* ys, int* widths, int* heights);

/*
Summary:
    Sets faces into objects for tracking.
Parameters:
    objectHandler - [in] pointer to object handler entity
    objectsCount - [in] count of object entities
    objects - [in/out] array of pointers to object entities
    facesCount - [in] number of faces that should be set into objects
    faces - [in] array of detected faces to be set into objects
Return value:
    error code
*/
IFACE_API int IFACE_SetFacesToTrackingObjects( void* objectHandler, int objectsCount, void** objects, int facesCount, void** faces );

/*
Summary:
    Sets important areas of scene for tracking using given mask. The value (0, 0, 0) indicates
    unimportant image parts that are not searched during object tracking.
    Mask has to contain at least one unmasked, connected area in which a valid face can be identified and tracked (approximately
    it's pixel count should be above the second power of the minimum eye distance).
Parameters:
    objectHandler - [in] pointer to objectHandler entity
    rawImage - [in] pointer to raw image data, each pixel has a 3-channel component
    width - [in] width of input image. Minimal valid width can be retrieved
            from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
    height - [in] height of input image. Minimal valid height can be retrieved
             from parameter IFACE_PARAMETER_GLOBAL_MIN_VALID_IMAGE_SIZE.
Return value:
    error code
*/
IFACE_API int IFACE_SetTrackingAreaMask( void* objectHandler, unsigned char* rawImage, int width, int height );

/*
Summary:
    Cleans object entity. The function deletes all internal object data (e.g. tracking information).
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
Return value:
    error code
*/
IFACE_API int IFACE_CleanObject( void* object, void* objectHandler );

/*
Summary:
    Returns object id from given object entity.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    id - [out] id of the object
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectId( void* object, void* objectHandler, int* id);

/*
Summary:
    Returns object bounding box from given object entity.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    x - [out] x-coordinate of bounding box of the object
    y - [out] y-coordinate of bounding box of the object
    w - [out] width of bounding box of the object
    h - [out] height of bounding box of the object
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectBoundingBox( void* object, void* objectHandler, float* x, float* y, float* w, float* h);

/*
Summary:
    Returns object bounding box trajectory from given object entity.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    trajectoryLength - [in/out] in: number of wanted bounding boxes from the tracking history (most recent),
                       out: number of returned bounding boxes as output.
                       If 0 or negative value is given, the length of the full history is returned.
    x - [out] x-coordinates of bounding boxes of the object.
        If x is NULL, only trajectory length is returned.
    y - [out] y-coordinates of bounding boxes of the object
    w - [out] width of bounding boxes of the object
    h - [out] height of bounding boxes of the object
    time - [out] timestamps of the bounding boxes of the object
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectTrajectory( void* object, void* objectHandler, int* trajectoryLength, float* x, float* y, float* w, float* h, long long* time);

/*
Summary:
    Returns object state from given object entity.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    state - [out] State of the object (see details in <c>IFACE_TrackedObjectState</c>)
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectState( void* object, void* objectHandler, IFACE_TrackedObjectState* state);

/*
Summary:
    Returns object type from given object entity.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    type - [out] type of the object (see details in <c>IFace_TrackedObjectType</c>)
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectType( void* object, void* objectHandler, IFace_TrackedObjectType* type);

/*
Summary:
    Returns object score from given object entity.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    score - [out] score of the object from range <0, MAX_FACE_CONFIDENCE>.
            The higher the value of the score the higher confidence in the object.
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectScore( void* object, void* objectHandler, float* score);

/*
Summary:
    Returns the object tracking time range.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    timeAppearance - [out] time of appearance (tracking start) in ms
    timeLost - [out] time of disappearance (tracking end) in ms
Return value:
    error code
*/
IFACE_API int IFACE_GetObjectTiming( void* object, void* objectHandler, long long* timeAppearance, long long* timeLost );

/*
Summary:
    Function returns entities detected in given object.
Parameters:
    object -        [in] pointer to object entity.
    objectHandler - [in] pointer to objectHandler entity. Type of object must be compatible with type of entity
                    in entities array
    entitiesCnt -   [in/out] in: max count of entities to be detected in given object, out: count of detected entities
    entities -      [in/out] in: array of pointers entities created by <c>IFACE_CreateEntity</c>, out: same entities,
                    filled with detection information
Return value:
    error code
*/
IFACE_API int IFACE_DetectInObject( void* object, void* objectHandler, int* entitiesCnt, void** entities);

/*
Summary:
    Function returns particular type of face entity related to given object entity.
Parameters:
    object - [in] pointer to object entity.
    objectHandler - [in] pointer to objectHandler entity
    face - [out] face entity stored within object entity copied to given preallocated face entity
    typeOfFace - [in] type of wanted face entity (see <c>IFACE_TrackedObjectFaceType</c>)
Remarks:
    This function is deprecated in favor of <c>IFACE_DetectInObject</c>
Return value:
    error code
*/
IFACE_API int IFACE_GetFaceFromObject( void* object, void* objectHandler, void* face, IFACE_TrackedObjectFaceType typeOfFace);

/*
Summary:
    Estimates, merges and returns unique objects representing valid faces based on an array of objects.
Parameters:
    objectHandler - [in] pointer to objectHandler entity
    objects - [in] array of object entity pointers from which the unique objects are estimated
    uniqueObjects - [in/out] in: array of pointers to object entities, out: same entities filled with the unique object data
    objCount - [in/out] in: number of object passed to the function in both arrays, out: number of unique objects
Remarks:
    Not available in IFace Tiny edition
Return value:
    error code
*/
IFACE_API int IFACE_EstimateUniqueObjects( void* objectHandler, void** objects, void** uniqueObjects, int* objCount );

/*
Summary:
    Sets the position of the dot on a the screen as a part of the face liveness evaluation.
    Has to be invoked in a moment (specified by <c>timeStampMs</c>) when user is looking at the dot on the screen.
    Has to be followed with <c>IFACE_TrackObjects</c> call.
Parameters:
    objectHandler - [in] pointer to objectHandler entity
    dotPositionX - [in] position of the dot on the screen along the X axis (0 is the leftmost side).
                   Should be from the range <0,100>, however only values from ranges <0,10> and <90,100> are valid for X position.
    dotPositionY - [in] position of the dot on the screen along the Y axis (0 is the topmost side).
                   Should be from the range <0,100>, however only values from ranges <0,20> and <80,100> are valid for Y position.
    timeStampMs - [in] number of milliseconds from the first frame of the video
Return value:
    error code
*/
IFACE_API int IFACE_SetLivenessDotPosition( void* objectHandler, int dotPositionX, int dotPositionY, long long timeStampMs );

/*
Summary:
    Returns the liveness state of the object.
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    livenessState - [out] liveness state of the object (see details in <c>IFACE_LivenessState</c>)
    framesCount - [out] number of registered frames of the object
Return value:
    error code
*/
IFACE_API int IFACE_GetLivenessState( void* object, void* objectHandler, IFACE_LivenessState* livenessState, int* framesCount );

/*
Summary:
    Returns the liveness score of the object if the liveness evaluation was successful
    (see details in <c>IFACE_LivenessState</c> and <c>IFACE_GetLivenessState</c>).
Parameters:
    object - [in] pointer to object entity
    objectHandler - [in] pointer to objectHandler entity
    score - [out] liveness score of the object
Remarks:
    Valid liveness score is defined over the interval [0,1] and is set to -1
    in case the liveness evaluation was unsuccessful (liveness state is not
    <c>IFACE_LIVENESS_STATE_FINISHED_ENOUGH</c> or <c>IFACE_LIVENESS_STATE_INPROGRESS_ENOUGH</c>).
Return value:
    error code
*/
IFACE_API int IFACE_GetLivenessScore( void* object, void* objectHandler, float* score );

/*
Summary:
    Serializes entity content to byte array. Face and object entities are supported.
Parameters:
    entity - [in] pointer to entity
    serializedEntity - [in/out] in: pointer to an allocated array that will be filled with serialized
                       entity data, out: filled data
    serializedEntitySize - [in/out] in: size of the allocated array, out: size of serialized entity data
Remarks:
    If <c>serializedEntity==NULL<c/> then just size of serialized entity is returned.
    IFACE_SerializeEntity is often called subsequently twice. First call with <c>serializedEntity==NULL<c/> only returns
    <c>serializedEntitySize</c> filled. Second call is performed with preallocated array <c>serializedEntity</c>.
    The entity must not be changed between these calls, otherwise IFACE_ERR_PARAM_BUFFER_SIZE is returned.
Return value:
    error code
*/
IFACE_API int IFACE_SerializeEntity( void* entity, char* serializedEntity, int* serializedEntitySize);

/*
Summary:
    Deserialize entity content from byte array. Face and object entities are supported.
Parameters:
    entity - [in/out] in: pointer to a entity, out: pointer to the entity, filled with serialized entity data
    serializedEntity - [in] pointer to memory filled with serialized entity data
    serializedEntitySize - [in] length of data in serializedEntity array
Return value:
    error code
*/
IFACE_API int IFACE_DeserializeEntity( void* entity, char* serializedEntity, int serializedEntitySize);

/*
Summary:
    Function that clone entities. Currently only face entity is supported.
Parameters:
    entitySrc - [in] pointer to source entity.
    entityDst - [in/out] in: pointer to an already allocated entity, out: filled entity
Return value:
    error code
*/
IFACE_API int IFACE_CloneEntity( void* entitySrc, void* entityDst);


/*
Summary:
    Releases all types of data entities (face, faceHandler, objectHandler, object, etc).
Parameters:
    entity - [in] data entity to be released
Return value:
    error code
*/
IFACE_API int IFACE_ReleaseEntity( void* entity);

#ifdef __cplusplus
}
#endif

#endif //_IFACE_H
