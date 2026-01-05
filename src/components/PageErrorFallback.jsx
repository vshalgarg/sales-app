import React from 'react'
import {Alert,Button} from "@mui/material"

const PageErrorFallback = ({error,resetErrorBoundary}) => {
  return (
    <div className='p-8 text-center bg-white'>
     <Alert severity='error' sx={{mb:8}}>
 <strong>Something went wrong on this wrong:</strong>{error.message}
        </Alert>
        <Button variant='contained' color="primary" onClick={resetErrorBoundary}> Retry loading</Button>
      
    </div>
  )
}

export default PageErrorFallback

