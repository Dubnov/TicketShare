from pyrebase import pyrebase
import numpy
import pandas as pd
from scipy.spatial.distance import cosine

def main():

    serverAddress = 'https://ticketshare-5ca22.firebaseio.com/'
    storageBucket = 'ticketshare-5ca22.appspot.com'
    apiKey = 'AIzaSyC6UvaY0O8BX08jwkTGoiZNMQ-ReNPFvJQ'
    authDomain = "ticketshare-5ca22.firebaseapp.com"
    email = 'bar320@gmail.com'
    password = 'Aa123456'

    config = \
    {
      "apiKey": apiKey,
      "authDomain": authDomain,
      "databaseURL": serverAddress,
      "storageBucket": ""
    }

    firebase = pyrebase.initialize_app(config)

    # Get a reference to the auth service
    auth = firebase.auth()

    # Log the user in
    user = auth.sign_in_with_email_and_password(email, password)

    # Get a reference to the database service
    db = firebase.database()
    purchases = db.child("purchases").get()
    users = db.child("users").get()
    tickets = db.child("tickets").get()

    matrix = numpy.zeros((len(users.val()) + 1,len(tickets.val()) + 1))

    for i in range(len(tickets.val()) + 1):
        matrix[0][i] = i

    for i in range(len(users.val()) + 1):
        matrix[i][0] = i

    ticketArray = {}
    indx = 0
    for ticket in tickets.each():
        ticketId = ticket.key()
        ticketArray[indx] = ticketId
        indx+=1

    for purchase in purchases.each():
        buyer = purchase.val().get('buyer')
        ticketId = purchase.val().get('ticketId')
        buyerIndx = users.val().keys().index(buyer) + 1
        ticketIndx = tickets.val().keys().index(ticketId) + 1
        matrix [buyerIndx][ticketIndx] = 1

    data_frame = pd.DataFrame(data=matrix,copy=True)
    data_recommend = calcItemBased(data_frame)
    print data_recommend

    indx = 0
    for user in users.each():
        buyerId = user.key()
        data_recommend.iloc[indx][0] = buyerId
        indx += 1

    for i in range(0,len(data_recommend.index)):
        for j in range(1,len(data_recommend.columns)):
            data_recommend.iloc[i,j] = (ticketArray[data_recommend.iloc[i,j] - 1])
    print data_recommend.iloc[:,:]

    UpdateRecommendaionTable(db,data_recommend)

    print

def UpdateRecommendaionTable(firebase_db,data_recomended):

    firebase_db.child("recommendations").remove()
    data = {}
    for i in range(0,len(data_recomended.index)):
        currentUserData = {}
        for j in range(1,len(data_recomended.columns)):
            currentUserData['ticketdid' + str(j)] = data_recomended.iloc[i,j]
        data[data_recomended.iloc[i,0]] = currentUserData

    firebase_db.child("recommendations").set(data)

def calcItemBased(data):


    # --- Start Item Based Recommendations --- #
    # Drop any column named "user"
    data_germany = data.drop(data.index[0], axis = 1)


    # Create a placeholder dataframe listing item vs. item
    data_ibs = pd.DataFrame(index=data_germany.columns, columns=data_germany.columns)

    # Lets fill in those empty spaces with cosine similarities
    # Loop through the columns

    columns_size = len(data_ibs.columns)

    for i in range(0, columns_size):
        # Loop through the columns for each column
        for j in range(0, columns_size):
            # Fill in placeholder with cosine similarities
            data_ibs.iloc[i, j] = 1 - cosine(data_germany.iloc[:, i], data_germany.iloc[:, j])


    # Create a placeholder items for closes neighbours to an item,  and grabbing the index of each of the top 5 tickets
    data_neighbours = pd.DataFrame(index=data_ibs.columns, columns=[range(1, 6)])

    # Loop through our similarity dataframe and fill in neighbouring item names
    for i in range(0, len(data_ibs.columns)):
        data_neighbours.iloc[i, :5] = data_ibs.iloc[0:, i][:5].index
    # --- End Item Based Recommendations --- #

    # --- Start User Based Recommendations --- #
    # Helper function to get similarity scores
    def getScore(history, similarities):
        return sum(history * similarities) / sum(similarities)

    # Create a place holder matrix for similarities, and fill in the user name column
    data_sims = pd.DataFrame(data=data)

    data_sims.iloc[:, :1] = data.iloc[:, :1]

    # Loop through all rows, skip the user column, and fill with similarity scores
    for i in range(0, len(data_sims.index)):
        for j in range(1, 9):
            user = data_sims.index[i]
            product = data_sims.columns[j]

            if data.iloc[i][j] == 1:
                data_sims.iloc[i][j] = 0
            else:
                product_top_names = data_neighbours.iloc[product][1:10]
                product_top_sims = data_ibs.iloc[product].sort_values(ascending=False)[1:10]
                user_purchases = data_germany.iloc[user, product_top_names]
                data_sims.iloc[i][j] = getScore(user_purchases, product_top_sims)

    # Get the top songs
    data_recommend = pd.DataFrame(index=data_sims.index, columns=['user', '1', '2', '3', '4', '5', '6'])
    data_recommend.ix[0:, 0] = data_sims.iloc[:, 0]

    # Instead of top song scores, we want to see names
    for i in range(0, len(data_sims.index)):
        print i
        data_recommend.iloc[i, 1:] = data_sims.iloc[i, :].sort_values(ascending=False).iloc[1:7, ].index.transpose()

    # Print a sample
    return data_recommend.iloc[1:100, :]

if __name__ == "__main__":
    main()