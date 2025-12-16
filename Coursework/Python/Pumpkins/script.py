# importing the main libraries. pandas for data handling and matplotlib/seaborn for creating plots

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# reading in the CSV file into a pandas DataFrame

df = pd.read_csv("pumpkins.csv")

# Q2.Finds the largest value in the weight_lbs column
# This gives the weight of the heaviest pumpkin in the dataset
max_weight = df["weight_lbs"].max()

# This finds the row in the table where the pumpkin's weight is equal to that of the maximum value
heaviest_pumpkin = df[df["weight_lbs"] == max_weight].iloc[0]

# Print variety, where it was from and when it was grown (using id field because it contains year)
print("Heaviest pumpkin:")
print("Variety:", heaviest_pumpkin["variety"])
print("Where:", heaviest_pumpkin["city"], heaviest_pumpkin["state_prov"], heaviest_pumpkin["country"])
print("When:", heaviest_pumpkin["id"])
print("Weight (lbs):", heaviest_pumpkin["weight_lbs"])

# Q3. This function takes the weight in pounds and converts it to kilograms
def lbs_to_kg(lbs):
    return lbs * 0.45359237 

# Q4. Adding a new column called weight_kg to existing dataframe using function
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

# Q5. Plotting estimated weight vs actual weight
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

# Q6. Filtering data to only contain data from 3 countries
# I chose the three countries with the most entries, United States, Canada and Germany
chosen_countries = ["United States", "Canada", "Germany"]

# Keeping the rows where the country is one of the chosen countries
df_filtered = df[df["country"].isin(chosen_countries)]

# Saving the filtered dataset to a new CSV file
df_filtered.to_csv("pumpkins_filtered.csv", index=False) # this is to remove the dataframe's row numbers as the extra first column

# Q7. Grouping the filtered data by country, and then calculating the mean weight
mean_by_country = df_filtered.groupby("country")["weight_kg"].mean() #groupby splits the table into separate groups, one group per country.

print("Mean pumpkin weight (kg) by country:", mean_by_country)

# idxmax () here will give the country name that has the highest mean
highest_mean = mean_by_country.idxmax()
print("Country with the highest mean weight (kg):", highest_mean)

# Calculating the average pumpkin weight for each combo of pumpkin and variety mean_by_country_variety = df_filtered.groupby(["country", "variety"])["weight_kg"].mean() 
# groupby is used to group the rows by both country and variety
mean_country_variety = df_filtered.groupby(["country", "variety"])["weight_kg"].mean()

# idxmin here returns the country/variety pair with the lowest mean value
lowest_country_variety = mean_country_variety.idxmin()

# printing results 
print("Mean pumpkin weight (kg) by country and variety:", mean_country_variety)
print("Lowest mean weight (kg) by country and variety:", lowest_country_variety)

# Q8. creating a boxplot to compare the pumpkin weight distirbution (kg) across the three countries
plt.figure()
sns.boxplot(data=df_filtered, x="country", y="weight_kg")

# adding labels and title
plt.xlabel("Country")
plt.ylabel("Pumpkin Weight (kg)")
plt.title("Pumpkin Weight Distributions Across Three Countries")

# Q9. Creating a facet plot, splitting the data by variety
facet_plot = sns.catplot(
    data=df_filtered,
    x="country",
    y="weight_kg",
    col="variety",
    kind="box",
    col_wrap=3, # shows 3 plots per row
    hue="country"
)

# Setting x and y axis labels, I don't use plt.xlabel/plt.ylabel here so it is easier to set it for all figures
facet_plot.set_axis_labels("Country", "Pumpkin weight (kg)")

# adding one title for the entire figure
facet_plot.fig.suptitle("Pumpkin Weight Distributions Across Three Countries (split by variety)", y=1.01) # y=1.01 moves the title above plot area



