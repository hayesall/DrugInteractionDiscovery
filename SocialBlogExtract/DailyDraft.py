from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains


chrome_path = r"C:\Users\ss95\Desktop\chromedriver.exe"
driver = webdriver.Chrome(chrome_path)
driver.get("https://www.dailystrength.org/search?query=drugs%20interactions")

        
for i in range(1,30):
        driver.execute_script("window.scrollTo(0, 0)") #Scroll up
       # if i>10:
        #driver.find_element_by_xpath("""//*[@id="show-more"]""").click()
              
       # time.sleep(1)
        try:
                driver.find_element_by_xpath("""//*[@id="main-content"]/div[4]/div[2]/div[2]/div/ul/li[{0:d}]/div[1]/div[1]/h2/a""".format(i)).click()
        except Exception as e:
                print(e)
        #Scroll to element
      
        
        posts = driver.find_elements_by_class_name("posts__content")
        for post in posts:
                print(post.text)

        comments = driver.find_elements_by_class_name("comments__comment")
        for comment in comments:
                print(comment.text)

        driver.back()
        driver.execute_script("window.scrollTo(0, 0)") #Scroll up
        #time.sleep(2)
        print(i)
        #if i>=10:
##                menu=driver.find_element_by_xpath("""//*[@id="show-more"]""")
##                actions = ActionChains(driver)
##                actions.move_to_element(menu)
##                actions.click(menu)
##                actions.perform()
        time.sleep(1)
        driver.find_element_by_xpath("""//*[@id="show-more"]""").click()
        time.sleep(1)
                
                        #element= WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID,'show-more')))
               # driver.execute_script("return arguments[0].scrollIntoView();", element)
               # element = driver.find_element_by_xpath("""//*[@id="main-content"]/div[4]/div[2]/div[2]/div/ul/li[{0:d}]/div[1]/div[1]/h2/a""".format(i))
                #element.click()
                #posts = driver.find_elements_by_class_name("posts__content")
                #for post in posts:
                 #       print(post.text)
##                comments = driver.find_elements_by_class_name("comments__comment")        
##                for comment in comments:
##                        print(comment.text)
##                print(i)
##                driver.back()
                #scroll to bottom
                #driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

        #driver.get("https://www.dailystrength.org/search?query=drug%20interactions")

