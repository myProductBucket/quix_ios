//
//  global.h
//  Quix
//
//  Created by Matti Heikkinen on 12/23/15.
//  Copyright © 2015 self. All rights reserved.
//

#ifndef global_h
#define global_h

#import "ProgressHUD.h"
#import "AFNetworking.h"
#import "NSDictionary+RJSON.h"
#import "UITextField+Utility.h"
#import "NSString+Utility.h"
#import "CustomTextView.h"
#import "NonRotateImagePickerController.h"
#import "JDDroppableView.h"

#import "UIViewController+OrientationFix.h"
#import "UIImagePickerController+UIImagePickerController_OrientationFix.h"

#define ROOTURL @"..."

#pragma mark - Teacher Info
#define USERID @"userID"
#define USERTOKEN @"userToken"
#define USEREMAIL @"userEmail"
#define USERPHOTOURL @"userProfilePicture"
#define USERNAME @"userName"

#pragma mark - Student Info
#define STUDENTNAME @"studentname"
//Exam info for Student
#define QUIZ_SOLVED @"quiz solved"//number
#define QUESTIONS_SOLVED @"questions solved"//number
#define AVERAGE_SCORE @"average score"//number
#define CORRECT @"correct"//percentage (%)
#define AVERAGE_QUIZTIME @"average quiz time"//time(12:30)
#define HIGHEST_SCORE @"highest score"//number
#define ISUPGRADE @"is upgraded"//upgrading

#define LIMITEDQUIZNUM 3

#pragma mark - url-key
#define REGISTER @"/register.php"
#define ADDQUIZ @"/addQuiz.php"
#define GETQUIZES @"/getQuizes.php"
#define DELETEQUIZ @"/deleteQuiz.php"
#define UPDATEQUIZ @"/updateQuiz.php"
#define ADDQUESTION @"/addQuestion.php"
#define GETQUESTIONS @"/getQuestions.php"
#define DELETEQUESTION @"/deleteQuestion.php"
#define GETANSWERS @"/getAnswers.php"
#define UPDATEQUESTION @"/updateQuestion.php"
#define UPDATEANSWER @"/updateAnswer.php"
#define SAVERESULTS @"/saveResults.php"
#define QUESTIONSTATS @"/questionStats.php"
#define GETRESULTS @"/getResults.php"
#define EXAMQUESTIONS @"/examQuestions.php"

//Quiz
#pragma mark - Quiz
#define QUIZNAME @"subject"
#define QUIZTYPE @"quiz_type"
#define QUIZID @"quiz_id"
#define QUIZTIME @"time"
#define NUMOFQUESTIONS @"question_count"
#define TEACHERID @"teacher_id"

//Question
#pragma mark - Question
#define QUESTIONNAME @"text"
#define FEEDBACK @"feedback"
#define ATTACHMENT @"attachment"
#define ANSWERS @"answers"
#define QUESTIONID @"id"

//Answers
#pragma mark - Answers
#define ANSWERTEXT @"text"
#define CORRECT @"correct"
#define FEEDBACK @"feedback"
#define MATCH @"match"
#define ANSWERID @"id"

//for only testing
#pragma mark - For testing
#define TESTUSERID @"**************"

#define COPYEDQUIZID @"**********"

//Specific Question Result Set
#pragma mark - Specific Question Result Set
#define RESULT_QUESTIONID @"id"
#define RESULT_QUESTIONTEXT @"question"
#define RESULT_CORRECTANSWER @"correct_answer"
#define RESULT_USERSFIRSTANSWER @"users_first_answer"
#define RESULT_ISCORRECT @"isCorrect"
#define RESULT_FIRSTCORRECT @"first_try_correct"
#define RESULT_SECONDCORRECT @"second_try_correct"
#define RESULT_THIRDCORRECT @"third_try_correct"

//Specific Quiz Result Set
#pragma mark - Specific Quiz Result Set
#define RESULT_QUIZ_QUIZID @"quiz_id"
#define RESULT_QUIZ_STUDENTNAME @"student_name"
#define RESULT_QUIZ_TIME @"time"
#define RESULT_QUIZ_SCORE @"score"
#define RESULT_QUIZ_TOTALQUESTION @"total_question"
#define RESULT_QUIZ_CORRECTCOUNT @"correct_count"
//
#define     APP_LINK                     @"..."

#endif /* global_h */
