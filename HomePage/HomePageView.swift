//
//  HomePageView.swift
//  Fit Pantry
//
//  Created by Lexie Reddon on 11/29/24.
//  Edited by Heather Amistani on 03/29/2025
//

//Views:
//HomePageView
//ProgressView
//LogProgressView?


//import SwiftUI
//import Firebase
//import FirebaseFirestore
//
//struct HomePageView: View {
//
//    @ObservedObject var retrieveworkoutdata = RetrieveWorkoutData()
//    @Binding var showMenu: Bool
//    //@State private var currentProgress: Double = 0.5
//    //@State private var currentProgress: Double = 0.0
//    @State private var progressValues: [Double] = Array(repeating: 1, count: 7)
//    @State private var selectedDate: Date = Date()
//    @EnvironmentObject var mealManager: TodayMealManager
//
//    let dayIndex: Int = 1
//
//
//    var body: some View {
//
//        NavigationView{
//            ScrollView{
//                VStack(alignment: .leading, spacing: 80){
//
//                    HStack{
//                        Button(action: {
//                            withAnimation{
//                                self.showMenu = true
//                            }
//                        }){
//                            Image(systemName: "line.3.horizontal")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 30, height: 30)
//
//                        }
//                        .padding(.leading, 20)
//                        Spacer()
//                    }
//                }
//                VStack(alignment: .center, spacing: 20){
//                    ZStack{
//                        RoundedRectangle(cornerRadius: 18)
//                            .fill(Color("BackgroundColor"))
//                            .frame(width: 370, height: 150)
//
//                        Text("Welcome to Fit Pantry!")
//                            .font(.title)
//                            .fontWeight(.semibold)
//                            .foregroundColor(Color.white)
//                    }
//
//                    Text("Workout Progress")
//                        .font(.largeTitle)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding()
//                    HStack{
//                        ScrollView(.horizontal){
//                            HStack {
//                                ForEach(1..<7, id: \.self) { dayIndex in
//                                    VStack(spacing: 20) {
//                                        NavigationLink(destination: ProgressView()) {
//                                            ProgressRingView(progress: progressValues[dayIndex], ringWidth: 15)
//                                                .padding()
//                                                .background(Color("BackgroundColor"))
//                                                .foregroundColor(.white)
//                                                .cornerRadius(10)
//                                        }
//                                        Text("Day \(dayIndex)")
//                                                                }
//                                                            }
//                            }.padding(.leading, 20)
//                        }
//                    }
//
//                        Text("Today's Meals")
//                            .font(.largeTitle)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding()
////                        ScrollView(.horizontal){
////                            HStack{
////                                NavigationLink(destination: ProgressView()){
////                                    Image("Breakfast")
////                                        .resizable()
////                                        .aspectRatio(contentMode: .fit)
////                                        .frame(width: 150, height: 150)
////                                }
////                                NavigationLink(destination: ProgressView()){
////                                    Image("Lunch")
////                                        .resizable()
////                                        .aspectRatio(contentMode: .fit)
////                                        .frame(width: 150, height: 150)
////                                }
////                                NavigationLink(destination: ProgressView()){
////                                    Image("Dinner")
////                                        .resizable()
////                                        .aspectRatio(contentMode: .fit)
////                                        .frame(width: 150, height: 150)
////                                }
////                            }
////                        }
//
//                    ScrollView(.horizontal) {
//                        HStack {
//                            NavigationLink(destination: TodayMealView(
//                                selectedDate: selectedDate,
//                                mealType: type,
//                                meals: Binding(
//                                    get: { mealManager.getMeals(for: selectedDate, type: type) },
//                                    set: { mealManager.setMeals(for: selectedDate, type: type, meals: $0) }
//                                ),
//                                onRemove: { removedMeal in
//                                    let amountToRestore = removedMeal.consumedAmount ?? 0
//                                    updatePantryQuantity(docID: removedMeal.pantryDocID, amount: amountToRestore)
//                                }
//                            )) {
//                                Image("Breakfast")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 150, height: 150)
//                            }
//
//                            NavigationLink(destination: TodayMealView(
//                                mealType: .lunch,
//                                meals: Binding(
//                                    get: { mealManager.getMeals(for: selectedDate, type: .lunch) },
//                                    set: { mealManager.setMeals(for: selectedDate, type: .lunch, meals: $0) }
//                                ),
//                                onRemove: { removedMeal in
//                                    let amount = removedMeal.consumedAmount ?? 0
//                                    updatePantryQuantity(docID: removedMeal.pantryDocID, amount: amount)
//                                }
//                            )) {
//                                Image("Lunch")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 150, height: 150)
//                            }
//
//                            NavigationLink(destination: TodayMealView(
//                                mealType: .dinner,
//                                meals: Binding(
//                                    get: { mealManager.getMeals(for: selectedDate, type: .dinner) },
//                                    set: { mealManager.setMeals(for: selectedDate, type: .dinner, meals: $0) }
//                                ),
//                                onRemove: { removedMeal in
//                                    let amount = removedMeal.consumedAmount ?? 0
//                                    updatePantryQuantity(docID: removedMeal.pantryDocID, amount: amount)
//                                }
//                            )) {
//                                Image("Dinner")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 150, height: 150)
//                            }
//                        }
//                    }
//
//                        NavigationLink("Progress Calendar", destination: ProgressTrackerView())
//                            .font(.largeTitle)
//                    }
//                .onAppear {
//                    fetchAllDaysProgress()
//                }
//                }
//
//            }.accentColor(.background)
//
//        }
//
//    private func updatePantryQuantity(docID: String, amount: Double) {
//        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
//        let docRef = Firestore.firestore()
//            .collection("userData_test")
//            .document(userID)
//            .collection("pantry")
//            .document(docID)
//
//        docRef.updateData(["quantity": FieldValue.increment(amount)])
//    }
//
//    private func fetchAllDaysProgress() {
//        for dayIndex in 1..<7 { // Loop through all days
//            retrieveworkoutdata.countCompletedAndTotalExercises(for: selectedDate, dayIndex: dayIndex) { completed, total in
//                let progress = total > 0 ? Double(completed) / Double(total) : 0.0
//
//                DispatchQueue.main.async {
//                    // Update only the specific index in the array
//                    self.progressValues[dayIndex] = progress
//                    print("Updated Progress for Day \(dayIndex): \(progress * 100)%")
//                }
//            }
//        }
//    }
//
//    }
//
//
////
////    struct ProgressView: View {
////        var body: some View {
////            VStack{
////                Text("Progress View")
////            }
////
////        }
////    }
////
//struct HomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            HomePageView(showMenu: .constant(false))
//                .environmentObject(TodayMealManager())
//        }
//    }
//}

import SwiftUI
import Firebase
import FirebaseFirestore

struct HomePageView: View {
    @ObservedObject var retrieveworkoutdata = RetrieveWorkoutData()
    @Binding var showMenu: Bool
    @State private var progressValues: [Double] = Array(repeating: 1, count: 7)
    @State private var selectedDate: Date = Date()
    @EnvironmentObject var mealManager: TodayMealManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.showMenu = true
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }

                    VStack(alignment: .center, spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.orange))
                                .frame(width: 370, height: 150)

                            Text("Welcome to Fit Pantry!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                        }

                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal)

                        Text("Workout Progress")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()

                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(1..<7, id: \ .self) { dayIndex in
                                    VStack(spacing: 20) {
                                        NavigationLink(destination: ProgressView()) {
                                            ProgressRingView(progress: progressValues[dayIndex], ringWidth: 15)
                                                .padding()
                                                .background(Color("BackgroundColor"))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        Text("Day \(dayIndex)")
                                    }
                                }
                            }.padding(.leading, 20)
                        }

                        Text("Today's Meals")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()

                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(MealType.allCases, id: \.self) { type in
                                    NavigationLink(destination: TodayMealView(
                                        selectedDate: selectedDate,
                                        mealType: type,
                                        meals: Binding(
                                            get: { mealManager.getMeals(for: selectedDate, type: type) },
                                            set: { mealManager.setMeals(for: selectedDate, type: type, meals: $0) }
                                        ),
                                        onRemove: { removedMeal in
                                            let amount = removedMeal.consumedAmount ?? 0
                                            updatePantryQuantity(docID: removedMeal.pantryDocID, amount: amount)
                                        }
                                    )) {
                                        VStack {
                                            Image(type.rawValue)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 150, height: 150)
                                            Text(type.rawValue)
                                                .font(.headline)
                                        }
                                    }
                                }
                            }.padding(.horizontal)
                        }

                        NavigationLink("Progress Calendar", destination: ProgressTrackerView())
                            .font(.largeTitle)
                    }
                }
                .onAppear {
                    fetchAllDaysProgress()
                }
            }
            .accentColor(.background)
        }
    }

    private func updatePantryQuantity(docID: String, amount: Double) {
        let userID = "Uhq3C2AQ05apw4yETqgyIl8mXzk2"
        let docRef = Firestore.firestore()
            .collection("userData_test")
            .document(userID)
            .collection("pantry")
            .document(docID)

        docRef.updateData(["quantity": FieldValue.increment(amount)])
    }

    private func fetchAllDaysProgress() {
        for dayIndex in 1..<7 {
            retrieveworkoutdata.countCompletedAndTotalExercises(for: selectedDate, dayIndex: dayIndex) { completed, total in
                let progress = total > 0 ? Double(completed) / Double(total) : 0.0
                DispatchQueue.main.async {
                    self.progressValues[dayIndex] = progress
                    print("Updated Progress for Day \(dayIndex): \(progress * 100)%")
                }
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(showMenu: .constant(false))
            .environmentObject(TodayMealManager())
    }
}
