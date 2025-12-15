# importing the main libraries. pandas/numpy for data handling and matplotlib/seaborn for creating plots

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# reading in the CSV file into a pandas DataFrame

df = pd.read_csv("pumpkins.csv")

# Finds the largest value in the weight_lbs column
# This gives the weight of the heaviest pumpkin in the dataset
max_weight = df["weight_lbs"].max()

# This finds the row in the table where the pumpkin's weight is equal to that of the maximum value
heaviest_pumpkin = df[df["weight_lbs"] == max_weight].iloc[0]

# Print variety, where it was from and when it was grown (using id field because it contains year)
print("Heaviest pumpkin:")
print("Variety:", heaviest_pumpkin["variety"])
print("Where:", heaviest_pumpkin["city"], heaviest_pumpkin["state_prov"], heaviest_pumpkin["country"])
print("When (id):", heaviest_pumpkin["id"])
print("Weight (lbs):", heaviest_pumpkin["weight_lbs"])

# This function takes the weight in pounds and converts it to kilograms
def lbs_to_kg(lbs):
    return lbs * 0.45359237 

# Adding a new column called weight_kg to existing dataframe using function
df["weight_kg"] = df["weight_lbs"].apply(lbs_to_kg)

# Creating a function that takes pumpkin weight (in kg) and returns the class as text
# light = < 400
# medium = 400 - 800
# heavy = > 800
def classify_weight_kg(w):
    if w < 400:
        return "light"
    elif w < 800:
        return "medium"
    else:
        return "heavy"

# Create the weight_class column by applying the classify_weight_kg function to each weight_kg value
df["weight_class"] = df["weight_kg"].apply(classify_weight_kg)

# Plotting estimated weight vs actual weight
# Converting est_weight into kg so both axes match
df["est_weight_kg"] = df["est_weight"].apply(lbs_to_kg)

# Removing rows where estimated weight is 0 to clean up final p>
df_plot = df[df["est_weight_kg"] > 0]

# x axis = estimated weight (kg)
# y axis = actual weight (kg)
# colour = weight_class (light/medium/heaby)
plt.figure()
sns.scatterplot(data=df_plot, x="est_weight_kg", y="weight_kg", hue="weight_class")

# Adding labels and titles
plt.xlabel("Estimated weight (kg)")
plt.ylabel("Actual weight (kg)")
plt.title("Estimated vs actual pumpkin weight")

plt.savefig("q5_est_vs_actual.png", dpi=200)
plt.close()
