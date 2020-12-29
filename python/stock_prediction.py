import pandas as pd
import sys
import json
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report
from utils import data_string_to_float, status_calc

# The percentage by which a stock has to beat the S&P500 to be considered a 'buy'
OUTPERFORMANCE = int(sys.argv[1])


def build_data_set():
    """
    Reads the keystats.csv file and prepares it for scikit-learn
    :return: X_train and y_train numpy arrays
    """
    training_data = pd.read_csv("keystats.csv", index_col="Date")
    training_data.dropna(axis=0, how="any", inplace=True)
    features = training_data.columns[6:]

    X_train = training_data[features].values
    y_train = list(
        status_calc(
            training_data["stock_p_change"],
            training_data["SP500_p_change"],
            OUTPERFORMANCE,
        )
    )

    return X_train, y_train


def predict_stocks():
    X_train, y_train = build_data_set()
    clf = RandomForestClassifier(n_estimators=100)
    clf.fit(X_train, y_train)
    data = pd.read_csv("forward_sample.csv", index_col="Date")
    data.dropna(axis=0, how="any", inplace=True)
    features = data.columns[6:]

    X_test = data[features].values
    y_test = list(
        status_calc(
            data["stock_p_change"],
            data["SP500_p_change"],
            OUTPERFORMANCE,
        )
    )
    z = data["Ticker"].values
    
    retval = {}
    y_pred_test = clf.predict(X_test)
    if sum(y_pred_test) == 0:
        retval['msg'] = 'No Stocks predicted'
    else:
        invest_list = z[y_pred_test].tolist()
        retval['stocks'] = invest_list
        retval['accuracy_score'] = accuracy_score(y_test, y_pred_test)
        retval['confusion_matrix'] = confusion_matrix(y_test, y_pred_test).tolist()
        retval['classification_report'] = classification_report(y_test, y_pred_test, zero_division=0)

    print(json.dumps(retval))


if __name__ == "__main__":
    predict_stocks()
