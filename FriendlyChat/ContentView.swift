//
//  ContentView.swift
//  FriendlyChat
//
//  Created by AUNG PHYO on 7/11/20.
//  Copyright © 2020 AUNG PHYO. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var name = ""
    
    var body: some View {
        NavigationView{
            
            ZStack{
                
                Color.orange
                
                VStack{
                    
                    Image(systemName: "person.circle.fill").resizable().frame(width: 60, height: 60).padding(.top, 12)
                    
                    TextField("Name", text: $name).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    
                    if self.name != ""{
                        
                        NavigationLink(destination: MsgPage(name: self.name)){
                                               
                            HStack{
                                Text("Join")
                                Image(systemName: "arrow.right.circle.fill").resizable().frame(width: 20, height: 20)
                                                   
                            }
                        }.frame(width: 100, height: 54)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(27)
                            .padding(.bottom, 15)
                    }
                   
                }.background(Color.white)
                 .cornerRadius(20)
                 .padding()
                
            }.edgesIgnoringSafeArea(.all)
            
        }.animation(.default)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MsgPage : View {
    
    var name = ""
    @ObservedObject var msg = observer()
    @State var typedmsg = ""
    
    var body : some View{
     
        VStack{
            List(msg.msgs){i in
                //Text(i.msg)
                if i.name == self.name{
                    
                    MsgRow(msg: i.msg, myMsg: true, user: i.name)
                    
                }else{
                    
                    MsgRow(msg: i.msg, myMsg: false, user: i.name)
                    
                }
                
            }.navigationBarTitle("Chats", displayMode: .inline)
            
            HStack{
                TextField("msg", text: $typedmsg).textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    self.addMsg(msg: self.typedmsg, user: self.name)
                    self.typedmsg = ""
                }){
                    Text("Send")
                }
            }.padding()
        }
    }
    
    func addMsg(msg : String, user : String){
        
        let db = Firestore.firestore()
        
        db.collection("msgs").addDocument(data: ["msg": msg, "name": user]){(err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            print("Success")
        }
    }
}

class observer : ObservableObject{
    
    @Published var msgs = [datatype]()
    
    init(){
        
        let db = Firestore.firestore()
        
        db.collection("msgs").addSnapshotListener{ (snap, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documentChanges{
                
                if i.type == .added{
                    let name = i.document.get("name") as! String
                    let msg = i.document.get("msg") as! String
                    let id = i.document.documentID
                    
                    self.msgs.append(datatype(id: id, name: name, msg: msg))
                }
            }
            
        }
    }
}

struct datatype : Identifiable{
    
    var id : String
    var name : String
    var msg : String
}

struct MsgRow : View{
    
    var msg = ""
    var myMsg = false
    var user = ""
    
    var body : some View{
        
        HStack{
            if myMsg{
                
                Spacer()
                Text(msg).padding(8).background(Color.blue).cornerRadius(6).foregroundColor(Color.white)
            }else{
                
                VStack(alignment: .leading){
                    Text(msg).padding(8).background(Color.green).cornerRadius(6).foregroundColor(Color.white)
                    Text(user)
                }
                Spacer()
            }
        }
    }
}
