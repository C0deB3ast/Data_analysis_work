CREATE TABLE credit_risk (
    person_age SMALLINT,
    person_income INT,
    person_home_ownership VARCHAR(20),
    person_emp_length NUMERIC,
    loan_intent VARCHAR(30),
    loan_grade CHAR(1),
    loan_amnt INT,
    loan_int_rate NUMERIC,
    loan_status SMALLINT,
    loan_percent_income NUMERIC,
    cb_person_default_on_file CHAR(1),
    cb_person_cred_hist_length SMALLINT
);

\copy credit_risk FROM 'credit_risk_dataset.csv' DELIMITER ',' CSV HEADER;

SELECT COUNT(*) FROM credit_risk;