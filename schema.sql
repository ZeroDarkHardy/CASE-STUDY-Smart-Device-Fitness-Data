CREATE TABLE IF NOT EXISTS user_ids(
   Id BIGINT  NOT NULL PRIMARY KEY 
);

CREATE TABLE IF NOT EXISTS daily_activity(
   Id                       BIGINT  NOT NULL
  ,ActivityDate             DATE  NOT NULL
  ,TotalSteps               INTEGER  NOT NULL
  ,TotalDistance            VARCHAR(19) NOT NULL
  ,TrackerDistance          NUMERIC(19,13) NOT NULL
  ,LoggedActivitiesDistance NUMERIC(16,13) NOT NULL
  ,VeryActiveDistance       NUMERIC(18,13) NOT NULL
  ,ModeratelyActiveDistance NUMERIC(19,13) NOT NULL
  ,LightActiveDistance      NUMERIC(19,13) NOT NULL
  ,SedentaryActiveDistance  NUMERIC(19,0) NOT NULL
  ,VeryActiveMinutes        INTEGER  NOT NULL
  ,FairlyActiveMinutes      INTEGER  NOT NULL
  ,LightlyActiveMinutes     INTEGER  NOT NULL
  ,SedentaryMinutes         INTEGER  NOT NULL
  ,Calories                 INTEGER  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS daily_calories(
   Id          BIGINT  NOT NULL
  ,ActivityDay DATE  NOT NULL
  ,Calories    INTEGER  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS daily_intensities(
   Id                       BIGINT  NOT NULL 
  ,ActivityDay              DATE  NOT NULL
  ,SedentaryMinutes         INTEGER  NOT NULL
  ,LightlyActiveMinutes     INTEGER  NOT NULL
  ,FairlyActiveMinutes      INTEGER  NOT NULL
  ,VeryActiveMinutes        INTEGER  NOT NULL
  ,SedentaryActiveDistance  NUMERIC(19,0) NOT NULL
  ,LightActiveDistance      NUMERIC(19,13) NOT NULL
  ,ModeratelyActiveDistance NUMERIC(19,13) NOT NULL
  ,VeryActiveDistance       NUMERIC(18,13) NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS daily_steps(
   Id          BIGINT  NOT NULL
  ,ActivityDay DATE  NOT NULL
  ,StepTotal   INTEGER  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS heartrate_seconds(
    Id                      BIGINT NOT NULL,
    Time                    DATETIME  NOT NULL,
    Value                   INTEGER NOT NULL,
    CONSTRAINT FK_CustId FOREIGN KEY (Id)
    REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS hourly_calories(
   Id           BIGINT  NOT NULL
  ,ActivityHour TIMESTAMP NOT NULL
  ,Calories     INTEGER  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS hourly_intensities(
   Id               BIGINT  NOT NULL
  ,ActivityHour     TIMESTAMP NOT NULL
  ,TotalIntensity   INTEGER  NOT NULL
  ,AverageIntensity NUMERIC(8,6) NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS hourly_steps(
   Id           BIGINT  NOT NULL
  ,ActivityHour TIMESTAMP NOT NULL
  ,StepTotal    INTEGER  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS minute_calories(
    Id                         BIGINT NOT NULL,
    ActivityMinute             TIMESTAMP  NOT NULL,
    Calories                   NUMERIC(18, 16) NOT NULL,
    CONSTRAINT FK_CustId FOREIGN KEY (Id)
    REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS minute_intensities(
    Id                      BIGINT NOT NULL,
    ActivityMinute          TIMESTAMP  NOT NULL,
    Intensity               INTEGER NOT NULL,
    CONSTRAINT FK_CustId FOREIGN KEY (Id)
    REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS minute_mets(
    Id                      BIGINT NOT NULL,
    ActivityMinute          TIMESTAMP  NOT NULL,
    METs                    INTEGER NOT NULL,
    CONSTRAINT FK_CustId FOREIGN KEY (Id)
    REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS minute_sleep(
   Id    BIGINT  NOT NULL
  ,date  TIMESTAMP  NOT NULL
  ,value INTEGER  NOT NULL
  ,logId BIGINT  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS minute_steps(
    Id                      BIGINT NOT NULL,
    ActivityMinute          TIMESTAMP  NOT NULL,
    Steps                   INTEGER NOT NULL,
    CONSTRAINT FK_CustId FOREIGN KEY (Id)
    REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS sleep_day(
   Id                 BIGINT  NOT NULL 
  ,SleepDay           DATE  NOT NULL
  ,TotalSleepRecords  INTEGER  NOT NULL
  ,TotalMinutesAsleep INTEGER  NOT NULL
  ,TotalTimeInBed     INTEGER  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);

CREATE TABLE IF NOT EXISTS weight_log(
   Id             BIGINT  NOT NULL 
  ,Date           TIMESTAMP NOT NULL
  ,WeightKg       NUMERIC(16,1) NOT NULL
  ,WeightPounds   NUMERIC(16,11) NOT NULL
  ,Fat            NUMERIC(4,0)
  ,BMI            NUMERIC(16,2) NOT NULL
  ,IsManualReport BOOLEAN  NOT NULL
  ,LogId          BIGINT  NOT NULL,
  CONSTRAINT FK_CustId FOREIGN KEY (Id)
  REFERENCES user_ids(Id)
);