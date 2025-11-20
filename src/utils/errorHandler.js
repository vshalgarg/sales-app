export const logicalError=(data)=>{
  if(data.code){
    throw new Error(data.message)
  }
  return data
}