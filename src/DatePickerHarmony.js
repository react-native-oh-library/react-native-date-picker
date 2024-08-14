import React from 'react'

import NativeDatePickerView from './NativeDatePickerView'


/** @type {React.FC<PlatformPickerProps>} */
export const DatePickerHarmony = React.memo((props) => {

 const modifiedProps = {
    ...props,
    date: props.date&&props.date.toDateString&&props.date.toDateString(),
    minimumDate: props.minimumDate&&props.minimumDate.toDateString&&props.minimumDate.toDateString(),
    maximumDate: props.maximumDate&&props.maximumDate.toDateString&&props.maximumDate.toDateString(),
 }
    
  //@ts-ignore
  return <NativeDatePickerView {...modifiedProps} />
})



export default DatePickerHarmony;
