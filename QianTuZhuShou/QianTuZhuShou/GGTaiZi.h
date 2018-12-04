
//  Created by 向日葵 on 16/7/12.
//
//

#ifndef GGtypedef_h
#define GGtypedef_h


#endif /* GGtypedef_h */


typedef enum
{
    
    GGSuccess = 1, /**< 成功 */
    GGerror = 2,   /**< 失败 */
    GGparametererror = 3,   /**< 参数错误 ［ key||pid = nil ］*/
    GGdataerror = 4  /**< 未接收到数据,或数据格式异常 */
    
}GGRequest;


typedef enum
{
    GGchaping = 1,  /**< 插屏   */
    GGshiping = 2,  /**< 视频   */
    
    
}GGType;



typedef enum
{
    
    GGviewSuccess = 1,         /**< 成功 */
    GGviewerror = 2,           /**< 失败 */
    GGviewClose= 3,            /**< 取消 */
    GGviewlink= 4,             /**< 跳出 */
    
    
}GGview;


typedef enum
{
    
    GGviewspStart = 1,    /**< 开始播放 */
    GGviewspClose = 2,    /**< 关闭播放 */
    GGviewspSuccess = 3,  /**< 播放成功 */
    GGviewsperror = 4,    /**< 播放错误 */
    GGviechapingStart=5,   /**< 插屏成功 */
    GGviechapingerror=6,   /**< 插屏失败 */
    GGviechapingClose=7,   /**< 插屏取消 */
    GGviechapingwlink=8,   /**< 插屏跳出 */

    
    
}GGviewsp;


typedef enum
{
    GGintegonquery = 1, /**< 查询  */
    GGintegplus = 2,    /**< 加积分 */
    GGintegreduce= 3,   /**< 减积分 */
    
}GGintegn; //积分





